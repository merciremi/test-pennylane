require 'rails_helper'

RSpec.describe RecipesController, type: :request do
  describe 'GET /recipes/:id' do
    subject(:action) { get "/recipes/#{recipe.id}" }

    let(:recipe) { Recipe.create(title: 'Vampire Burger', author: 'Buffy The Slayer', rating: 4.9, image: 'https://fakeimg.pl/300/') }

    before { action }

    it { expect(response).to be_successful }
    it { expect(response.body).to include('Vampire Burger') }
  end

  describe 'GET /recipes/search' do
    subject(:action) { get '/recipes/search', params: params }

    let!(:recipe) do
      Recipe.create(
        title: 'Vampire Burger',
        author: 'Buffy The Slayer',
        rating: 4.9,
        image: 'https://fakeimg.pl/300/',
        ingredients: ['2 cups of vampire ash', '1 cup of sugar', 'some butter', '1 teaspoon of baking powder', 'bake for 30 seconds in full sun']
      )
    end

    let!(:recipe02) do
      Recipe.create(
        title: 'Chocolate cookies',
        author: 'Remi',
        rating: 4.8,
        image: 'https://fakeimg.pl/300/',
        ingredients: ['300gr of chocolate', '1 cup of butter', '100g of sugar', '3 eggs']
      )
    end

    let!(:recipe03) do
      Recipe.create(
        title: 'Foccaccia',
        author: 'Bob',
        rating: 5,
        image: 'https://fakeimg.pl/300/',
        ingredients: ['1kg of flour', '300g of potato mash', '600gr of water', '20g of yeast', '1 teaspoon of sugar']
      )
    end

    let(:params) do
      {
        recipe: {
          ingredients: ingredients
        }
      }
    end

    context 'when the user inputs ingredients' do
      let(:ingredients) { %w[sugar butter] }

      it 'returns recipes which use all ingredients', :aggregate_failures do
        action

        expect(response.body).to include('Vampire Burger')
        expect(response.body).to_not include('Foccaccia')
      end

      it 'return an :ok response' do
        action

        expect(response).to be_successful
      end
    end

    # We can replicate the logic of these tests in a test dedicated to the query onject
    # and keep these as a kind of acceptance test.
    context 'when the user does not input ingredients' do
      let(:ingredients) { [] }

      it 'returns an :ok response' do
        action

        expect(response).to be_successful
      end

      it 'returns all recipes', :aggregate_failures do
        action

        expect(response.body).to include('Vampire Burger')
        expect(response.body).to include('Foccaccia')
        expect(response.body).to include('Chocolate cookies')
      end
    end
  end
end
