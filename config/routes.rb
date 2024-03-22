Rails.application.routes.draw do
  root to: 'games#index'

  resources :games, only: %i[create show] do
    collection do
      post :setup
    end

    member do
      get :join, as: :join
      post :new_player, as: :new_player
      patch :start, as: :start
      post :player_turn, as: :player_turn
      post :last_player_turn, as: :last_player_turn
      post :choose_last_cards, as: :choose_last_cards
    end

    resources :players, only: %i[create] do
      member do
        patch :ready, as: :ready
      end
    end
  end
end
