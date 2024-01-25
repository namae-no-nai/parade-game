class Board < ApplicationRecord
	has_many :player_cards, as: :owner
	has_many :cards, through: :player_cards

	def self.create_with_initial_parade(deck, parade)
    board = create!
    deck.pop(parade).each do |card|
      board.player_cards.create!(card: card, place: 'Board')
    end
    board
  end
end
