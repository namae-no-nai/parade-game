# frozen_string_literal: true

class Game::PlayersComponent < ApplicationComponent
  def initialize(players:, current_player:)
    @players = players
    @current_player = current_player
  end
end
