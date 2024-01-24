class Board < ApplicationRecord
	has_many :player_cards, as: :owner
end
