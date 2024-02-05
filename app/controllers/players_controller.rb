# frozen_string_literal: true

class PlayersController < ApplicationController
  before_action :set_game
  before_action :set_current_player, only: %i[ready]

  def create
    @player = @game.players.new(name: player_params[:name])
    if @player.save
      create_game_session
      redirect_to game_path(@game)
    else
      render 'games/join', status: :unprocessable_entity
    end
  end

  def ready
    if @current_player.update(status: :ready)
      redirect_to game_path(@game)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def player_params
    params.require(:player).permit(:name)
  end
end
