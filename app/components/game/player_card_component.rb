# frozen_string_literal: true

class Game::PlayerCardComponent < ApplicationComponent
  def initialize(player_card:, player:, selectable: false)
    @player_card = player_card
    @player = player
    @selectable = selectable
  end
end
