class RecipesController < ApplicationController
  def index
    @recipes = Recipe.where(":ingredients = ANY (ingredients)", ingredients: 'bread').limit(10)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
