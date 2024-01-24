class Card < ApplicationRecord
	validates :suit, :value, presence: true
	has_one :player_card
	has_one :owner, through: :player_card
end
