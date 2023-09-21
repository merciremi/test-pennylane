require 'json'

namespace :recipes do
  desc 'Import recipes from JSON'
  task import: :environment do
    serialized_recipes = File.read('lib/data/recipes-en.json')
    recipes = JSON.parse(serialized_recipes)

    recipes_payload = recipes.map do |recipe|
      {
        title: recipe['title'],
        author: recipe['author'],
        image: recipe['image'],
        prep_time: recipe['prep_time'],
        cook_time: recipe['cook_time'],
        rating: recipe['ratings'],
        ingredients: recipe['ingredients']
      }
    end

    Recipe.insert_all!(recipes_payload) if recipes_payload.present?

    # If this task was a regular routine, I'd add a rescuing mechanism to store
    # faulty recipes, without interrupting the import.
  end
end
