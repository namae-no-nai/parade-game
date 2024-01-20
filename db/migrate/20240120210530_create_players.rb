class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :hand_cards, array: true, default: []
      t.string :table_cards, array: true, default: []
      t.string :name

      t.timestamps
    end
  end
end
