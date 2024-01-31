class PlayerCard < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :card, inverse_of: :player_card

  delegate :suit, :value, to: :card

  scope :on_table, -> { where(place: 'Table') }
  scope :on_hand, -> { where(place: 'Hand') }

  def send_to_board(board)
    update!(owner: board, place: 'Board')
  end

  def compare_card_and_retreive(retrievable_cards:, owner:)
    retrievable_cards.each do |retrievable_card|
      if retrievable_card.suit == card.suit || retrievable_card.value <= card.value
        retrievable_card.update!(owner:, place: 'Table')
      end
    end
  end
end
