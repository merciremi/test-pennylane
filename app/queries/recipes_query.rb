# Simple query object to handle various query scenarios

class RecipesQuery
  def self.call(context = Recipe, ingredients)
    return context.search_by_ingredients(ingredients) if ingredients.present?

    context.all
  end
end
