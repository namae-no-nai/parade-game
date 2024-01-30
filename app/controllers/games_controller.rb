class GamesController < ApplicationController

  before_action :set_game, only: %w[ game player_turn ]

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
    retrieve_cards_to_player

    last_round if @game.player_cards.empty? || all_suits?

    draw_card

    render :game
  end

  def last_round
    # next_player
    push_into_parade

    retrieve_cards_to_player
    choose_last_two_cards

    #final_score if last_player?

  end

  def final_score
    #check who/s have the most card of the same suit, and sum those cards as +1 each
    #other cards should sum its values
    ## elsif game with 2 players the player with most cards of same suit should have more than 2 cards of same suit more than the other player
  end

  private def choose_last_two_cards
    @player.player_cards.on_hand
  end

  private def push_into_parade
    PlayerCard.card_ownership(
        card_id:game_params[:card_id],
        owner_id:game_params[:board_id]
      )
  end

  private def retrieve_cards_to_player
    card = PlayerCard.find(game_params[:card_id]).card
    return joker if card.value.zero?
    return if @board.player_cards.length <= card.value

    PlayerCard.compare_card_and_retreive(
      card:,
      retrievable_cards: @board.retrievable_cards(card),
      owner: @player
    )
  end

  private def joker
    # here the player could choose any card to be added to his table cards
    # he wants once a card with value 0 was added to the parade
    debugger
    @board.player_cards[1..]
  end

  private def compare_cards(card:, retrievable_cards:)
    bring_cards_to_player(card:, )
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
