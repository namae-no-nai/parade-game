class Game < ApplicationRecord
  include Cardable

  validates :started_at, :turn, presence: true

  has_one :board
  has_many :players
  has_many :game_logs
  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  enum :status, %i[waiting started last_rounds last_round finished]

  scope :ordered, -> { order(created_at: :desc) }
  scope :with_associations, ->(id) {
    includes(:board, :player_cards, players: { player_cards: :card })
      .find(id)
  }
  scope :joinable, -> { left_outer_joins(:players).waiting.group(:id).having('count(players.id) < 6') }

  after_update_commit :broadcast_game_change

  INITIAL_HAND = 5
  INITIAL_PARADE = 6

  def name
    "Game #{id}"
  end

  def current_player_turn?(player)
    turn == player.turn_order && player.game_id == id
  end

  def initialize_game
    initialize_deck
    create_initial_board

    hand_cards = players.shuffle.map.with_index do |player, index|
      player.update!(turn_order: index + 1)
      hand_cards = cards.sample(INITIAL_HAND)
      player.add_cards(hand_cards, 'Hand')

      hand_cards
    end

    remove_cards hand_cards
  end

  def start_game
    if players.all?(&:ready?) && players.size.between?(2, 6)
      initialize_game
      update status: :started
    else
      errors.add(:players, 'must be between 2 and 6 and all players must be ready')
      false
    end
  end

  def draw_card(player)
    drawed_card = player_cards.first
    drawed_card.update(owner: player, place: 'Hand')
  end

  def next_turn!
    self.turn += 1
    self.turn = 1 if turn > players.size
    save!
  end

  def calculate_scores
    players.map do |player|
      most_owned_suits = players_most_owned_cards.select { |pmoc| pmoc[:player] == player }.map { |pmoc| pmoc[:suit] }
      score = player.player_cards.on_table.includes(:card).sum do |pc|
        most_owned_suits.include?(pc.card.suit) ? 1 : pc.card.value
      end

      { player:, score: }
    end
  end

  private

  def broadcast_game_change
    players.each do |player|
      ::BroadcastGame.send(game: self, current_player: player)
    end
  end

  def players_grouped_cards
    players.map do |player|
      {
        player:,
        grouped_cards: player.player_cards.on_table.joins(:card).group(:suit).count
      }
    end
  end

  def players_most_owned_cards
    Card::SUITS.map do |suit|
      player = players_grouped_cards.max_by { |pgc| pgc[:grouped_cards][suit].to_i }

      { suit:, player: player[:player], count: player[:grouped_cards][suit].to_i }
    end
  end

  def initialize_deck
    return if player_cards.any?

    add_cards(Card.shuffled_deck, 'Deck')
  end

  def create_initial_board(deck = cards)
    return if board.present?

    deck_cards = deck.sample(INITIAL_PARADE)
    board = Board.create!(game: self)
    board.add_cards(deck_cards, 'Board')

    remove_cards deck_cards
  end
end
