class Board < ApplicationRecord
  include Cardable

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards
end
