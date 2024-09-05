# frozen_string_literal: true

# The class RecipesQuery is a service-object-like abstraction that handles related things:
# - normalizing of the user input
# - leveraging PostgreSQL full-text search capabilities to query the table `recipes`
# - weighting the various columns as to return a collection sorted by `most relevant`
# - falling back on a more permissive query if no results are returned the first time
#
# As of now, the RecipeQuery has no flags available to sort the collection differently.
# But through an extra argument, this would allow the user to rank the collection against other
# criterias:
# - most relevant: a ratio favoring PostgreSQL ts_rank over recipes' ratings (current strategy)
# - highest rating: a ratio favoring recipes' rating over PostgreSQL ts_rank
class RecipesQuery
  INGREDIENTS_WEIGHT = 0.9
  RATING_WEIGHT = 0.1

  attr_reader :context, :ingredients, :normalized_ingredients, :recipes, :fallback

  def initialize(context = Recipe, ingredients)
    @context = context
    @ingredients = ingredients
    @normalized_ingredients = set_normalized_ingredients
  end

  def self.call(...) = new(...).call

  # Documentation by Remi - 4 Sep 2024
  #
  # TODO:
  # [ ] Add vectorized columns for ingredients and title
  # [ ] Add index on vectorized columns
  # [ ] Handle fuzzy matching
  def call
    @recipes ||= begin
      context
        .where("#{ingredients_query} OR #{title_query}", normalized_ingredients, normalized_ingredients)
        .order(Arel.sql("#{rank} desc"))
    end

    @recipes = fallback_collections if @recipes.empty?

    self
  end

  private

  def rank
    @rank ||= begin
      <<~RANK
        (#{INGREDIENTS_WEIGHT} * ts_rank(#{ingredients_vector}, websearch_to_tsquery('english', '#{normalized_ingredients}'))) +
        (#{RATING_WEIGHT} * rating)
      RANK
    end
  end

  def ingredients_query
    "setweight(#{ingredients_vector}, 'A') @@ #{query_vector}"
  end

  def title_query
    "setweight(#{title_vector}, 'B') @@ #{query_vector}"
  end

  def ingredients_vector
    "to_tsvector('english', COALESCE(ingredients::text, ''))"
  end

  def title_vector
    "to_tsvector('english', COALESCE(title::text, ''))"
  end

  def query_vector
    "websearch_to_tsquery('english', ?)"
  end

  def set_normalized_ingredients
    return [] if ingredients.empty?

    ingredients
      .join(' ')
      .split(/[\s+ | ,+ | ;+ | :+]/)
      .reject(&:empty?)
      .join(',')
  end

  def fallback_collections
    @fallback = true

    if ingredients.present?
      or_ingredients = normalized_ingredients.presence.gsub(',', ' OR ')

      context.where("#{ingredients_query} OR #{title_query}", or_ingredients, or_ingredients).order(rating: :desc).limit(10)
    else
      context.all.order(rating: :desc).limit(10)
    end
  end

  # Documentation by Remi - 4 Sep 2024
  #
  # This method adds an extra layer of sanitation but the syntax is more convulated.
  # As of now, I keep it here as a reminder.
  def _rank_with_extra_sanitation
    @rank ||= begin
      ActiveRecord::Base.sanitize_sql_array([<<~RANK, normalized_ingredients])
        (#{INGREDIENTS_WEIGHT} * ts_rank(#{ingredients_vector}, websearch_to_tsquery('english', ?))) +
        (#{RATING_WEIGHT} * rating)
      RANK
    end
  end
end
