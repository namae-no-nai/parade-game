class PlayerCard < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :card, inverse_of: :player_card

  delegate :suit, :value, to: :card
  delegate :game, to: :owner

  scope :on_table, -> { where(place: 'Table') }
  scope :on_hand, -> { where(place: 'Hand') }

  after_update_commit :broadcast_change

  def send_to_board(board)
    update!(owner: board, place: 'Board')
  end

  def compare_card_and_retreive(retrievable_cards:, owner:)
    retrievable_cards.each do |retrievable_card|
      if retrievable_card.suit == card.suit || retrievable_card.value.to_i <= card.value.to_i
        retrievable_card.update!(owner:, place: 'Table')
      end
    end
  end

  private

  def broadcast_change
    partial_name = owner_type.downcase
    locals = {}.tap do |h|
      h[owner_type.downcase.to_sym] = owner
    end

    broadcast_replace_to game, target: owner, partial: "games/#{partial_name}", locals:
  end
end
