class Game < ApplicationRecord
  include Cardable

  validates :started_at, :turn, presence: true

  has_one :board
  has_many :players
  has_many :game_logs
  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  scope :with_associations, ->(id) {
    includes(:board, :player_cards, players: { player_cards: :card })
    .find(id)
  }

  INITIAL_HAND = 5
  INITIAL_PARADE = 6

  def initialize_game(new_players)
    if new_players.size < 2 || new_players.size > 6
      errors.add(:players, 'must be between 2 and 6')
      return
    end

    initialize_deck
    create_players(new_players)
    create_initial_board
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

  def broadcast_game_change
    broadcast_replace_to self, target: self, partial: 'games/game', locals: { game: self }
  end

  private

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

  def create_players(new_players, deck = cards)
    return if players.any?

    hand_cards = new_players.map do |player_name|
      player = players.create!(name: player_name)

      hand_cards = deck.sample(INITIAL_HAND)
      player.add_cards(hand_cards, 'Hand')

      hand_cards
    end.flatten

    remove_cards hand_cards
  end

  def create_initial_board(deck = cards)
    return if board.present?

    deck_cards = deck.sample(INITIAL_PARADE)
    board = Board.create!(game: self)
    board.add_cards(deck_cards, 'Board')

    remove_cards deck_cards
  end
end
