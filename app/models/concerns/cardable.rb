module Cardable
  def add_cards(cards, place)
    cards.each do |card|
      player_cards.create!(card:, place:)
    end
  end

  def remove_cards(cards)
    player_cards.where(card: cards).destroy_all
  end
end
