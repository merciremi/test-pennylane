class RecipesController < ApplicationController
  def index
    @recipes = Recipe.search_by_ingredients(recipe_params[:ingredients])
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
