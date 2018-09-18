# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_15_194459) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "uploader_id"
    t.bigint "parent_card_id"
    t.bigint "starting_games_user_id"
    t.bigint "idea_catalyst_id"
    t.text "description_text"
    t.integer "medium", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "out_of_game_card_upload", default: false, null: false
    t.index ["deleted_at"], name: "index_cards_on_deleted_at"
    t.index ["idea_catalyst_id"], name: "index_cards_on_idea_catalyst_id"
    t.index ["parent_card_id"], name: "index_cards_on_parent_card_id"
    t.index ["starting_games_user_id"], name: "index_cards_on_starting_games_user_id"
    t.index ["uploader_id"], name: "index_cards_on_uploader_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "game_type", default: 0
    t.integer "status", default: 0
    t.string "join_code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "passing_order", default: ""
    t.boolean "description_first", default: true
    t.index ["deleted_at"], name: "index_games_on_deleted_at"
  end

  create_table "games_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id"
    t.string "users_game_name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "set_complete", default: false
    t.index ["deleted_at"], name: "index_games_users_on_deleted_at"
    t.index ["game_id"], name: "index_games_users_on_game_id"
    t.index ["user_id"], name: "index_games_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
  end

end
