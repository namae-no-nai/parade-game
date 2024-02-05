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
    end

    resources :players, only: %i[create] do
      member do
        patch :ready, as: :ready
      end
    end
  end
end
