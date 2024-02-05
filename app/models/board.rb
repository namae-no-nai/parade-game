class Board < ApplicationRecord
  include Cardable

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  def retrievable_cards(card)
    player_cards.order(id: :desc)[..-card.value.to_i - 2]
  end
end
