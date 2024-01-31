Rails.application.routes.draw do
  root to: 'games#index'

  resources :games, only: %i[show] do
    collection do
      post :initialize_game
    end

    member do
      post :player_turn, as: :player_turn
    end
  end
end
