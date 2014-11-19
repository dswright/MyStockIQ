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

ActiveRecord::Schema.define(version: 20141109191321) do

  create_table "stocks", force: true do |t|
    t.string   "stock",                limit: 255
    t.string   "exchange",             limit: 255
    t.boolean  "active"
    t.string   "ticker_symbol",        limit: 255
    t.datetime "date"
    t.float    "daily_percent_change"
    t.integer  "daily_volume"
    t.float    "price_to_earnings"
    t.float    "ytd_percent_change"
    t.float    "daily_stock_price"
    t.string   "stock_industry",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stock_sector",         limit: 255
  end

  create_table "streams", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "streams", ["user_id", "created_at"], name: "index_streams_on_user_id_and_created_at"
  add_index "streams", ["user_id"], name: "index_streams_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest", limit: 255
    t.string   "remember_digest", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
