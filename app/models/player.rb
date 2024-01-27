class Player < ApplicationRecord
  include Cardable

  validates :name, presence: true

  belongs_to :game

  has_many :player_cards, as: :owner
  has_many :cards, through: :player_cards

  def all_suits?
    player_cards.on_table.group_by(&:suit).count == 6
  end
end
