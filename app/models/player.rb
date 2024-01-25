class Player < ApplicationRecord
	validates :name, presence: true
	has_many :player_cards, as: :owner
	has_many :cards, through: :player_cards


	def self.create_players_for_game(number_of_players, deck, hand)
    players = []

    number_of_players.to_i.times do |index|
      player = Player.create(name: "Player #{index + 1}")
      players << player
    end

    players.each do |player|
      deck.pop(hand).each do |card|
        player.player_cards.create!(card: card, place: 'Hand')
      end
    end

    players
  end
end
