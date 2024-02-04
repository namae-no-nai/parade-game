class Card < ApplicationRecord
  validates :suit, :value, presence: true
  has_one :player_card
  has_one :owner, through: :player_card

  SUITS = %w[Dodo MadHatter HumptyDumpty Alice CheshireCat WhiteRabbit].freeze

  def self.shuffled_deck
    all.shuffle
  end
end
