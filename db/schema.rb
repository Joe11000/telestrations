# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160116063308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.integer  "uploader_id"
    t.integer  "parent_card_id"
    t.integer  "idea_catalyst_id"
    t.text     "description_text",     default: ""
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "drawing_file_name"
    t.string   "drawing_content_type"
    t.integer  "drawing_file_size"
    t.datetime "drawing_updated_at"
    t.index ["deleted_at"], name: "index_cards_on_deleted_at", using: :btree
  end

  create_table "games", force: :cascade do |t|
    t.boolean  "is_private",               default: true
    t.boolean  "is_active",                default: true
    t.boolean  "allow_additional_players", default: true
    t.string   "join_code"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_games_on_deleted_at", using: :btree
  end

  create_table "games_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "users_game_name", default: "Ned Flanders"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_games_users_on_deleted_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "provider_avatar"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider_avatar_override_file_name"
    t.string   "provider_avatar_override_content_type"
    t.integer  "provider_avatar_override_file_size"
    t.datetime "provider_avatar_override_updated_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  end

end
