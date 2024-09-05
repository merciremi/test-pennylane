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

  attr_reader :context, :ingredients, :recipes, :fallback_collection

  def initialize(context = Recipe, ingredients)
    @context = context
    @ingredients = ingredients.join(',')

    @fallback_collection = false
  end

  def self.call(...) = new(...).call

  def call
    @recipes ||= begin
      context
        .where("searchable @@ #{query_vector}", ingredients)
        .order(Arel.sql("#{rank} desc"))
    end

    @recipes = fallback_collections if @recipes.empty?

    self
  end

  private

  def rank
    @rank ||= begin
      <<~RANK
        (#{INGREDIENTS_WEIGHT} * ts_rank(searchable, websearch_to_tsquery('english', '#{ingredients}'))) +
        (#{RATING_WEIGHT} * rating)
      RANK
    end
  end

  def query_vector(type: :websearch)
    "#{type.to_s}_to_tsquery('english', ?)"
  end

  def fallback_collections
    @fallback_collection = true

    if ingredients.present?
      or_ingredients = ingredients.presence.gsub(',', ' OR ')

      context.where("searchable @@ #{query_vector}", or_ingredients).order(rating: :desc).limit(10)
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
      ActiveRecord::Base.sanitize_sql_array([<<~RANK, ingredients])
        (#{INGREDIENTS_WEIGHT} * ts_rank(#{ingredients_vector}, websearch_to_tsquery('english', ?))) +
        (#{RATING_WEIGHT} * rating)
      RANK
    end
  end
end
