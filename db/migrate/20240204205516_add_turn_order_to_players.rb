class AddTurnOrderToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :turn_order, :integer

    Game.all.each do |game|
      game.players.each_with_index do |player, index|
        player.update!(turn_order: index + 1)
      end
    end

    change_column_null :players, :turn_order, false
  end
end
