class CreateGameLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :game_logs do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :action

      t.timestamps
    end
  end
end
