class AddLeaderToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :leader, :boolean, default: false, null: false
  end
end
