# frozen_string_literal: true

module GamesHelper
  def player_turn_border(player)
    'border-green-500' if player.turn_order == player.game.turn
  end

  def player_status_class(player)
    "text-#{player.status == 'waiting' ? 'yellow' : 'green'}-500"
  end
end
