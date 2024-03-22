# frozen_string_literal: true

class Game::BoardComponent < ApplicationComponent
  def initialize(game:, current_player:)
    @game = game
    @board = game.board
    @current_player = current_player
  end

  def board_cards
    @board.player_cards.ordered
  end

  def joker_play?
    @game.joker_play? && @game.current_player_turn?(@current_player)
  end
end
