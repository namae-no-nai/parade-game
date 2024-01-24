class CreatePlayerCards < ActiveRecord::Migration[7.0]
  def change
    create_table :player_cards do |t|
      t.string :owner_type, null: false
      t.bigint :owner_id, null: false
      t.references :card, null: false, foreign_key: true
      t.string :place, null: false, default: 'Deck'

      t.timestamps
    end
    add_index :player_cards, [:owner_id, :owner_type]
  end
end
