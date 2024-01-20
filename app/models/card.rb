class Card < ApplicationRecord
	validates :suit, :value, presence: true
end
