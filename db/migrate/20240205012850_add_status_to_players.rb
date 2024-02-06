class AddStatusToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :status, :integer, default: 0, null: false
  end
end
