class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :suit
      t.integer :value

      t.timestamps
    end
  end
end
