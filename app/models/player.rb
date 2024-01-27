class Player < ApplicationRecord
  include Cardable

  validates :name, presence: true

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards
end
