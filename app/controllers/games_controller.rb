class GamesController < ApplicationController

  DRAW_CARD = 1

  def index
    @game = Game.new
  end

  #colocar o numero de jogadores entre 2 e 6
  #cada jogador precisa de um nome
  #criar, checo a quantidade, e inicio o jogo

  def initialize_game
    @game = Game.create!(started_at: Time.current)
    @game.initialize_game(game_params[:players])
    return render :index, status: 400 if @game.errors.any?

    redirect_to game_path(@game)
  end

  def game
    game = Game.with_associations(params[:id])
    @players = game.players
    @board = game.board
  end

  def middle_game
    # o jogador adiciona uma carta ao board
    # ele verefica se precisa pegar alguma carta para adicionar a sua frente
    # verificar se tem uma carta de cada naipe ou não há mais cartas no deck
    # se sim fim de jogo, se não jogo continua
    # compra uma carta
    player_turn
  end

  def next_player;end

  def last_round; end

  def player_turn
    push_into_parade
    retrieve_cards_to_table(card)
    if @deck.is_zero? || all_suits
      last_round
    end
    draw_card
  end

  def last_round
    card = select_card(player)
    push_into_parade(card)
    retrieve_cards_to_table(card)
    choose_last_two_cards

    next_player
  end

  def choose_last_two_cards
    #escolhe 2 cards e encerra o jogo para o jogador
    #ainda pensando em como fazer isso, com tempo mas sem foco hoje T_T
  end

  def select_card(player)
    player.player_cards
  end

  private def push_into_parade
    card_ownership = PlayerCard.find(game_params[:card_id])
    card_ownership.update(owner_id: game_params[:board_id], owner_type: 'Board')
  end

  private def retrieve_cards_to_table(card)
    return joker if card.value.is_zero?
    return if @board.length <= card.value
    compare_cards(card:, retriavable_cards:  @board.player_cards[..(-card.value.to_i-1)])
  end

  def joker
    # here the player could choose any card to be added to his table cards
    # he wants once a card with value 0 was added to the parade
    parade[..-1]
  end

  private def compare_cards(card:, retriavable_cards:)
    unretriavable_cards = parade[0..card.value.to_i-1]
    retrievable_cards.reject! { |participant| player.table_cards << participant  if participant.suit == card[:suit] }
    retrievable_cards.reject! { |participant| player.table_cards << participant  if participant.value <= card[:suit] }
    parade = unretriavable_cards + retrievable_cards
  end

  private def draw_card
    player.hand_cards.concat(@shuffled_deck.pop(DRAW_CARD))
  end

  private def game_params
    params.require(:game).permit(:card_id, :board_id, :player_id, players:[])
  end
end
