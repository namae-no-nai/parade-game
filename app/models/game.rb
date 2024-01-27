class Game < ApplicationRecord
  include Cardable

  validates :started_at, presence: true

  has_one :board
  has_many :players
  has_many :game_logs
  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  INITIAL_HAND = 5
  INITIAL_PARADE = 6
  DRAW_CARD = 1

  def initialize_game(new_players)
    if new_players.size < 2 || new_players.size > 6
      errors.add(:players, 'must be between 2 and 6')
      return
    end

    initialize_deck
    create_players(new_players)
    create_initial_board
  end

  private

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
