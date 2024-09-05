class RecipesController < ApplicationController
  # GET /search
  def search
    query = RecipesQuery.call(ingredients)

    session[:normalized_ingredients] = query.normalized_ingredients

    @fallback = query.fallback

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

  def recipe_params
    params.require(:recipe).permit(ingredients: [])
  end
end
