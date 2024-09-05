# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root 'main#home'

  resources :recipes, only: %i[show] do
    collection do
      get 'search'
    end
  end
end
