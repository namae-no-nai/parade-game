class GamesController < ApplicationController

INITIAL_HAND = 5
INITIAL_PARADE = 6
DRAW_CARD = 1

	def index;end

	#colocar o numero de jogadores entre 2 e 6
	#cada jogador precisa de um nome
	#criar, checo a quantidade, e inicio o jogo

	def initialize_game
		@shuffled_deck = Card.all.shuffle
		@players = create_or_find_players
		@players.each do |player|
			@shuffled_deck.pop(INITIAL_HAND).each do |card|
				player.player_cards.create!(card: card, place:'Hand')
			end
		end
		make_parade
		render :game, status: 302
	end

	def middle_game
		# o jogador adiciona uma carta ao board
		# ele verefica se precisa pegar alguma carta para adicionar a sua frente
		# verificar se tem uma carta de cada naipe ou não há mais cartas no deck
		# se sim fim de jogo, se não jogo continua
		# compra uma carta
		player_turn

	def create_or_find_players
		game_params[:players].map do |player|
			Player.find_or_create_by!(name: player)
		end
	end

	def next_player;end

	def last_round; end

	def player_turn(player)
		card = select_card(player)
		push_into_parade(card)
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

	private def push_into_parade(card)
		@player.player_cards.card.update(owner: @board.id, owner_type: 'Board')
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

	private def make_parade
		@board = Board.create!
		@shuffled_deck.pop(INITIAL_PARADE).each do |card|
			@board.player_cards.create!(card:, place: 'Board')
		end
	end

  private def game_params
    params.require(:game).permit(players: [])
  end
end
