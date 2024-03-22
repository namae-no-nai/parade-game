# frozen_string_literal: true

class Game::WaitingPlayersComponent < ApplicationComponent
  def initialize(game:)
    @game = game
  end

end
