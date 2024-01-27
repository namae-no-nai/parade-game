class AddGameToBoards < ActiveRecord::Migration[7.0]
  def change
    add_reference :boards, :game, null: false, foreign_key: true
  end
end
