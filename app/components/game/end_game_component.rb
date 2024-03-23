# frozen_string_literal: true

class Game::EndGameComponent < ApplicationComponent
  def initialize(game:, current_player:)
    @game = game
    @current_player = current_player
  end

  def players_scores
    @game.calculate_scores.sort_by { |it| it[:score] }
  end
end
