# frozen_string_literal: true

class Game::PlayerComponent < ApplicationComponent
  def initialize(player:, current_player:)
    @player = player
    @current_player = current_player
    @game = player.game
  end

  def current_player?
    @player == @current_player
  end

  def player_name
    name = @player.name
    name += ' (You)' if @player == @current_player

    name
  end

  def selectable?
    current_player? && @game.current_player_turn?(@player)
  end

  def multi_selectable?
    # return false if @player.is_a?(Board)

    @player.game.last_round? && @player.ready?
  end

  def last_round?
    @game.last_round?
  end

  def current_player_border
    'border-green-500' if @game.current_player_turn?(@player)
  end
end
