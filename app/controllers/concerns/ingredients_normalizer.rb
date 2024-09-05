module IngredientsNormalizer
  extend ActiveSupport::Concern

  def normalize(ingredients)
    return [] if ingredients.empty?

    ingredients
      .join(' ')
      .split(/[\s+ | ,+ | ;+ | :+]/)
      .reject(&:empty?)
  end
end
