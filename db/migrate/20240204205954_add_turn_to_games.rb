class AddTurnToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :turn, :integer, default: 1, null: false
  end
end
