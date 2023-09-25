class RecipesController < ApplicationController
  before_action :set_ingredients, only: :index

  # GET /recipes
  def index
    @recipes = RecipesQuery.call(@ingredients).page(params[:page]).per(10)
  end

  # GET /recipes/:id
  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def set_ingredients
    # Fetch ingredients and remove empty string when user inputs nothing
    @ingredients = recipe_params[:ingredients].compact_blank
  end

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
