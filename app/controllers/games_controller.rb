# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :set_game, only: %i[show start player_turn]
  before_action :verify_player_turn, only: %i[player_turn]
  before_action :set_current_player, only: %i[show start]

  def index
    @game = Game.new
    @player = @game.players.new
  end

  def setup
    @game = Game.create!(started_at: Time.current, turn: 1)
    @game.initialize_game(game_params[:players])
    return render :index, status: 400 if @game.errors.any?

    redirect_to game_path(@game)
  end

  def create
    @game = Game.new(started_at: Time.current)
    if @game.save
      @player = @game.players.new(name: player_params[:name], leader: true, status: :ready)
      if @player.save
        create_game_session
        redirect_to game_path(@game)
      else
        render :index, status: :unprocessable_entity
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  def join
    @game = Game.find(params[:id])
    return redirect_to game_path(@game) if game_session

    @player = @game.players.new
  end

  def start
    @game = Game.find(params[:id])
    if @game.start_game
      redirect_to game_path(@game)
    else
      render :waiting_players_list, status: :unprocessable_entity
    end
  end

  def show
    case @game.status
    when 'waiting'
      render :waiting_players_list
    when 'started'
      render :game
    when 'finished'
      render :finished
    end
  end

  def player_turn
    @player_card = PlayerCard.find_by(id: game_params[:player_card_id])

    push_into_parade
    retrieve_cards_to_player

    last_round_conditions? ? last_round : draw_card
    @game.next_turn!
    @game.broadcast_game_change

    respond_to do |format|
      format.html { redirect_to game_path(@game) }
      format.turbo_stream
    end
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
    game = Game.find(game_id)

    suits = %w[Dodo MadHatter HumptyDumpty Alice CheshireCat WhiteRabbit ]

    suits.each do |suit|
      player_with_most_cards = game.players do |player|
        player.cards.where(suit:).count
      end
    end
  end

  private def choose_last_two_cards
    @player.player_cards.on_hand
  end

  private def push_into_parade
    @player_card.send_to_board(@board)
  end

  private def retrieve_cards_to_player
    card = @player_card.card
    return joker if card.value.to_i.zero?
    return if @board.player_cards.length <= card.value.to_i

    @player_card.compare_card_and_retreive(
      retrievable_cards: @board.retrievable_cards(card),
      owner: @player
    )
  end

  private def joker
    # here the player could choose any card to be added to his table cards
    # he wants once a card with value 0 was added to the parade
    @board.player_cards[1..]
  end

  private def all_suits?
    @player.all_suits?
  end

  private def draw_card
    @game.draw_card(@player)
  end

  private def last_round_conditions?
    @game.player_cards.empty? || all_suits?
  end

  private def next_player
    # we need to implement the order of the playerss
  end

  private def set_game
    @game = Game.with_associations(params[:id])
    @players = @game.players.includes(:player_cards)
    @board = @game.board
  end

  private def verify_player_turn
    redirect_to game_path(@game), notice: "It's not your turn yet, please wait" unless correct_player?
  end

  def correct_player?
    @player = @players.find(game_params[:player_id])
    @game.turn == @player.turn_order
  end

  private def player_params
    params.require(:player).permit(:name)
  end

  private def game_params
    params.require(:game).permit(:card_id, :board_id, :player_id, :player_card_id, players: [])
  end
end
