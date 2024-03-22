# frozen_string_literal: true

class GameComponent < ApplicationComponent
  def initialize(game:, current_player:)
    @game = game
    @current_player = current_player
  end
end
