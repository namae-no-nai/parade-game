# frozen_string_literal: true

class BroadcastGame
  def self.send(game:, current_player:)
    new(game:, current_player:).broadcast
  end

  def initialize(game:, current_player:)
    @game = game
    @current_player = current_player
  end

  def broadcast
    Turbo::StreamsChannel.broadcast_replace_to(
      @current_player,
      target: @game,
      html: rendered_component
    )
  end

  private

  attr_reader :game, :current_player

  def rendered_component
    ApplicationController.render(
      GameComponent.new(game:, current_player:),
      layout: false
    )
  end
end
