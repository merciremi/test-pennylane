class RecipesController < ApplicationController
  include IngredientsNormalizer

  # GET /search
  def search
    query = RecipesQuery.call(normalized_ingredients)

    @fallback_collection = query.fallback_collection
    @recipes = query.recipes.page(params[:page]).per(10)
  end

  # GET /recipes/:id
  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def ingredients
    @ingredients ||= recipe_params[:ingredients].compact_blank
  end

  def normalized_ingredients
    @normalized_ingredients ||= normalize(ingredients)
  end

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
