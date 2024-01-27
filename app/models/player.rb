class Player < ApplicationRecord
	validates :name, presence: true
	has_many :player_cards, as: :owner
	has_many :cards, through: :player_cards


	def self.create_players_for_game(players_names, deck, hand)
    players = []
    players_names.map do |player_name|
      players <<  Player.find_or_create_by!(name: player_name)
    end

    players.each do |player|
      deck.pop(hand).each do |card|
        player.player_cards.create!(card: card, place: 'Hand')
      end
    end

    players
  end
end
