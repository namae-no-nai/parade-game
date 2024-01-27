# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_27_011021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id", null: false
    t.index ["game_id"], name: "index_boards_on_game_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "suit"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_logs", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_logs_on_game_id"
    t.index ["player_id"], name: "index_game_logs_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_cards", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "card_id", null: false
    t.string "place", default: "Deck", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_player_cards_on_card_id"
    t.index ["owner_id", "owner_type"], name: "index_player_cards_on_owner_id_and_owner_type"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  add_foreign_key "boards", "games"
  add_foreign_key "game_logs", "games"
  add_foreign_key "game_logs", "players"
  add_foreign_key "player_cards", "cards"
  add_foreign_key "players", "games"
end
