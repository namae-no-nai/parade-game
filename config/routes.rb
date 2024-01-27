Rails.application.routes.draw do
  root to: 'games#index'

  post '/initialize_game', to: 'games#initialize_game'
  get '/game/:id', to: 'games#game', as: 'game'
end
