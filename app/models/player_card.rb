class PlayerCard < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :card, inverse_of: :player_card

  delegate :suit, :value, to: :card
  delegate :game, to: :owner

  scope :on_table, -> { where(place: 'Table') }
  scope :on_hand, -> { where(place: 'Hand') }
  scope :ordered, -> { order(updated_at: :desc) }

  def send_to_board(board)
    update!(owner: board, place: 'Board')
  end

  def send_to_table(player)
    update!(owner: player, place: 'Table')
  end

  def compare_card_and_retreive(retrievable_board_cards:, owner:)
    retrievable_board_cards.each do |retrievable_board_card|
      retrievable_card = retrievable_board_card.card
      if retrievable_card.suit == card.suit || retrievable_card.value <= card.value
        retrievable_board_card.update!(owner:, place: 'Table')
      end
    end
  end
end
