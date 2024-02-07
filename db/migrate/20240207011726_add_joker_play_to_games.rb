class AddJokerPlayToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :joker_play, :boolean, default: false, null: false
  end
end
