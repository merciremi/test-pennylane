# README

Welcome to my test application for Pennylane.

This minimal application runs with `ruby 3.1.2` and `rails 7.0.8`.

Its template was pulled from [RailsBytes](https://railsbytes.com/public/templates/x7msKX) with custom configuration adding PostgreSQL, Rubocop, RSpec, etc...

It can be accessed live here: https://test-pennylane.fly.dev/

# Summary

Create an application that helps users find the most relevant recipes that they can prepare with the ingredients they have at home.

# Users stories

1. As a user, I need to input ingredients that I have on hand.
2. As a user, I need to browse a list of selected recipes my highest relevancy.
3. As a user, I want to read the full details of the recipe.

# Input

The raw data is currently stored as a JSON:

```
[
  {
    "title": "Golden Sweet Cornbread",
    "cook_time": 25,
    "prep_time": 10,
    "ingredients": [
      "1 cup all-purpose flour",
      "1 cup yellow cornmeal",
      "⅔ cup white sugar",
      "1 teaspoon salt",
      "3 ½ teaspoons baking powder",
      "1 egg",
      "1 cup milk",
      "⅓ cup vegetable oil"
    ],
    "ratings": 4.74,
    "cuisine": "",
    "category": "Cornbread",
    "author": "bluegirl",
    "image": "https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F43%2F2021%2F10%2F26%2Fcornbread-1.jpg"
  },
  {
    "title": "Monkey Bread I",
    "cook_time": 35,
    "prep_time": 15,
    "ingredients": [
      "3 (12 ounce) packages refrigerated biscuit dough",
      "1 cup white sugar",
      "2 teaspoons ground cinnamon",
      "½ cup margarine",
      "1 cup packed brown sugar",
      "½ cup chopped walnuts",
      "½ cup raisins"
    ],
    "ratings": 4.74,
    "cuisine": "",
    "category": "Monkey Bread",
    "author": "deleteduser",
    "image": "https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F43%2F2018%2F11%2F546316.jpg"
  }...
]
```

Some interesting data points:
- `ratings` definitely needs to be used in the relevancy ponderation.
- `ingredients` is an array of full-text strings. We’ll need to have the appropriate type for this column (JSONB).

# Possible implementation

I'll keep the underlying structure as simple as possible to focus on the query itself.

Here's a possible implementation:

- `RecipesController` that'll pass the normalized input to an object handling the query.
- `IngredientsNormalizer` that'll act as a concern normalizing the input, most notably the ponctuation, etc...
- `RecipesQuery` that'll act both as a service-object and query object. It'll handle the main query, and defines alternative strategies if the main query returns an empty collection.

## Recipes Query

The main goal for me, during this second run, is to take a look under the hood of PostgreSQL full-text search capacities, most notable how vectors work.

## Domain Model

I'll keep this to a minimum:

```
Recipe {
  +String title
  +String author
  +String image
  +Int prep_time
  +Int cook_time
  +Float rating
  +Jsonb ingredients
}
```
