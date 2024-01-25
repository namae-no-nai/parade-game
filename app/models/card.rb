class Card < ApplicationRecord
	validates :suit, :value, presence: true
	has_one :player_card
	has_one :owner, through: :player_card

	def self.shuffled_deck
		all.shuffle
	end
end
