# frozen_string_literal: true

class BroadcastWaitingList
  def self.send(game:)
    new(game: game).broadcast
  end

  def initialize(game:)
    @game = game
  end

  def broadcast
    Turbo::StreamsChannel.broadcast_replace_to(
      @game,
      target: 'waiting_list',
      html: rendered_component
    )
  end

  private

  attr_reader :game

  def rendered_component
    ApplicationController.render(
      Game::WaitingPlayersComponent.new(game:),
      layout: false
    )
  end
end
