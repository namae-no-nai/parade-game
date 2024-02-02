Rails.application.routes.draw do
  root to: 'games#index'

  resources :games, only: %i[show] do
    collection do
      post :setup
    end

    member do
      post :player_turn, as: :player_turn
    end
  end
end
