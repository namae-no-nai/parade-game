# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def create_game_session
    return if game_session

    session[:games] << { id: @game.id, player_id: @player.id }
  end

  def game_session
    session[:games] ||= []
    @game_session ||= session[:games]&.find { |game| game['id'] == @game.id }
  end

  def set_current_player
    if game_session
      @current_player = @game.players.find(game_session['player_id'])
    else
      redirect_to join_game_path(@game) unless game_session
    end
  end
end
