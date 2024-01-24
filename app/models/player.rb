class Player < ApplicationRecord
	validates :name, presence: true
	has_many :player_cards, as: :owner
	has_many :cards, through: :player_cards
end
