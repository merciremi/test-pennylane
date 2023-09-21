class MainController < ApplicationController
  def home
    @recipe = Recipe.new
  end
end
