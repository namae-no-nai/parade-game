class Board < ApplicationRecord
  include Cardable

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  def retrievable_cards(card)
    self.player_cards[..-card.value-2]
  end
end
