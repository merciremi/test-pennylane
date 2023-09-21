module Queries
  class RecipesController < ApplicationController
    def index
      @recipes = Recipe.where(":ingredients = ANY (ingredients)", ingredients: 'bread').limit(10)
    end

    private

    def recipe_params
      params.require(:recipe).permit(ingredients: [])
    end
  end
end
