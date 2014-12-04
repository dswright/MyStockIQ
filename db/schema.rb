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

ActiveRecord::Schema.define(version: 20141204224851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "adminpack"

  create_table "stockprices", force: true do |t|
    t.string   "ticker_symbol"
    t.datetime "date"
    t.float    "open_price"
    t.float    "close_price"
    t.integer  "volume"
    t.integer  "split"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "stockprices", ["date"], name: "index_stockprices_on_date", using: :btree
  add_index "stockprices", ["ticker_symbol"], name: "index_stockprices_on_ticker_symbol", using: :btree

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

  add_index "stocks", ["active"], name: "index_stocks_on_active", using: :btree
  add_index "stocks", ["date"], name: "index_stocks_on_date", using: :btree
  add_index "stocks", ["exchange"], name: "index_stocks_on_exchange", using: :btree
  add_index "stocks", ["id"], name: "index_stocks_on_id", using: :btree
  add_index "stocks", ["stock_industry"], name: "index_stocks_on_stock_industry", using: :btree
  add_index "stocks", ["ticker_symbol"], name: "index_stocks_on_ticker_symbol", using: :btree
  add_index "stocks", ["updated_at"], name: "index_stocks_on_updated_at", using: :btree

  create_table "streams", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "streams", ["user_id", "created_at"], name: "index_streams_on_user_id_and_created_at", using: :btree
  add_index "streams", ["user_id"], name: "index_streams_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest", limit: 255
    t.string   "remember_digest", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
