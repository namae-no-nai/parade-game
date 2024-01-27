class PlayerCard < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :card, inverse_of: :player_card

  delegate :suit, :value, to: :card

  scope :on_table, -> { where(place: 'Table') }
  scope :on_hand, -> { where(place: 'Hand') }
end
