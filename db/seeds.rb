# # frozen_string_literal: true
# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Examples:
# #
# #   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
# #   Character.create(name: "Luke", movie: movies.first)

require 'json'

data_path = File.join(Rails.root, 'lib', 'data', 'recipes-en.json')
serialized_recipes = File.read(data_path)
recipes = JSON.parse(serialized_recipes)

recipes.each do |recipe|
  recipe_payload = {
    title: recipe['title'],
    author: recipe['author'],
    image: recipe['image'],
    prep_time: recipe['prep_time'],
    cook_time: recipe['cook_time'],
    rating: recipe['ratings'],
    ingredients: recipe['ingredients']
  }

  # No AR instantiation to circuvent Fly.io virtual memory limitation
  # No insert_all to avoid concurrent processes / interlocking on Fly.io
  Recipe.insert(recipe_payload)
end
