# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :set_game, only: %i[show start player_turn choose_last_cards last_player_turn]
  before_action :verify_player_turn, only: %i[player_turn]
  before_action :set_current_player, only: %i[show start player_turn choose_last_cards]

  def index
    @game = Game.new
    @joinable_games = Game.joinable
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
    @player = @game.players.build(name: player_params[:name], leader: true, status: :ready)

    if @game.save && @player.save
      create_game_session
      redirect_to game_path(@game)
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
      respond_to do |format|
        format.html { redirect_to game_path(@game) }
        format.turbo_stream { render_game_component }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  def show; end

  def player_turn
    return finish_joker_play if @game.joker_play

    @player_card = PlayerCard.find_by(id: game_params[:player_card_id])
    process_turn_actions

    @game.last_round! if last_round_condition_met?
    @game.game_logs.create!(player: @player, action: 'played')

    create_response_for_turbo_stream
  end

  def last_player_turn
    @player = Player.find(game_params[:player_id])
    PlayerCard.where(id: game_params[:player_cards]).each { |it| it.update!(place: 'Table') }
    @player.finished!

    finish_game if @game.players.all?(&:finished?)

    create_response_for_turbo_stream
  end

  def end_game
    @game = Game.find(params[:id])
  end

  def choose_last_cards
    @player = Player.find(game_params[:player_id])
    player_selected_card_ids = params[:player_card_ids]
    @player.player_cards.where(id: player_selected_card_ids).each { |it| it.update!(place: 'Table') }
    @player.finished!

    # redirect_to end_game_path(@game) if @game.players.all?(&:finished?)

    finish_game if @game.players.all?(&:finished?)

    create_response_for_turbo_stream
  end

  private

  def process_turn_actions
    push_into_parade
    retrieve_cards_to_player

    @game.draw_card(@player) unless @game.last_rounds? && @game.game_logs.last.player != @player
    @game.next_turn! unless @game.joker_play
    @game.last_rounds! if last_rounds_condition_met?
  end

  def render_game_component
    render turbo_stream: turbo_stream.replace(@game, GameComponent.new(game: @game, current_player:))
  end

  def last_round_condition_met?
    @game.players.all? { |player| player.player_cards.on_hand.size == 4 }
  end

  def last_rounds_condition_met?
    @game.last_rounds? && (@game.player_cards.empty? || all_suits?)
  end

  def finish_game
    @game.finished!
    redirect_to game_path(@game)
  end

  def finish_joker_play
    player_selected_card_ids = params[:player_card_ids]
    PlayerCard.where(id: player_selected_card_ids).each { |it| it.update!(owner: @player, place: 'Table') }
    @game.joker_play = false
    @game.next_turn!
    @game.last_rounds! if @game.player_cards.empty? || all_suits?

    create_response_for_turbo_stream
  end

  def create_response_for_turbo_stream
    respond_to do |format|
      format.html { redirect_to game_path(@game) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@game, GameComponent.new(game: @game, current_player:))
      end
    end
  end

  def push_into_parade
    @player_card.send_to_board(@board)
  end

  def retrieve_cards_to_player
    card = @player_card.card
    return @game.update!(joker_play: true) if card.value.zero?
    return if @board.player_cards.length <= card.value

    @player_card.compare_card_and_retreive(
      retrievable_board_cards: @board.retrievable_cards(card),
      owner: @player
    )
  end

  def draw_card
    @game.draw_card(@player)
  end

  def all_suits?
    @player.all_suits?
  end

  def set_game
    @game = Game.with_associations(params[:id])
    @players = @game.players.includes(:player_cards)
    @board = @game.board
  end

  def verify_player_turn
    redirect_to game_path(@game), notice: "It's not your turn yet, please wait" unless correct_player?
  end

  def correct_player?
    @player = @players.find(game_params[:player_id])
    @game.turn == @player.turn_order
  end

  def player_params
    params.require(:player).permit(:name)
  end

  def game_params
    params.require(:game).permit(:card_id, :board_id, :player_id, :player_card_id, players: [], player_cards: [])
  end
end
