class GamesController < ApplicationController

  before_action :set_game, only: %w[ game player_turn]

  def index
    @game = Game.new
  end

  def initialize_game
    @game = Game.create!(started_at: Time.current)
    @game.initialize_game(game_params[:players])
    return render :index, status: 400 if @game.errors.any?

    redirect_to game_path(@game)
  end

  def game; end

  def player_turn
    @player = @players.find(game_params[:player_id])

    push_into_parade
    retrieve_cards_to_table

    deck = @game.player_cards
    last_round if deck.empty? || all_suits?

    draw_card

    render :game
  end

  def last_round
    # push_into_parade(card)
    # retrieve_cards_to_table(card)
    # choose_last_two_cards

    # next_player
  end

  private def choose_last_two_cards
    #escolhe 2 cards e encerra o jogo para o jogador
    #ainda pensando em como fazer isso, com tempo mas sem foco hoje T_T
  end

  private def push_into_parade
    PlayerCard.card_ownership(
        card_id:game_params[:card_id],
        owner_id:game_params[:board_id]
      )
  end

  private def retrieve_cards_to_table
    card = PlayerCard.find(game_params[:card_id]).card
    return joker if card.value.zero?

    @board = Board.find(game_params[:board_id])
    return if @board.player_cards.length <= card.value

    compare_cards(card:, retriavable_cards: @board.player_cards[(card.value + 1)..])
  end

  private def joker
    # here the player could choose any card to be added to his table cards
    # he wants once a card with value 0 was added to the parade
    @board[..-1]
  end

  private def compare_cards(card:, retriavable_cards:)
    retriavable_cards.each do |retriavable_card|
      if retriavable_card.suit == card.suit || retriavable_card.value <= card.value
        retriavable_card.update!(owner: @player, place: 'Table')
      end
    end
  end

  private def all_suits?
    @player.all_suits?
  end

  private def draw_card
    @game.draw_card(@player)
  end

  def next_player;end

  private def set_game
    @game = Game.with_associations(params[:id])
    @players = @game.players
    @board = @game.board
  end

  private def game_params
    params.require(:game).permit(:card_id, :board_id, :player_id, players:[])
  end
end
