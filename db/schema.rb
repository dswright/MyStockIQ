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


ActiveRecord::Schema.define(version: 20150203070632) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.text     "content"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
    t.float    "popularity_score"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "intradayprices", force: true do |t|
    t.string   "ticker_symbol"
    t.datetime "date"
    t.float    "open_price"
    t.float    "close_price"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "intradayprices", ["date"], name: "index_intradayprices_on_date", using: :btree
  add_index "intradayprices", ["ticker_symbol"], name: "index_intradayprices_on_ticker_symbol", using: :btree

  create_table "likes", force: true do |t|
    t.string   "like_type"
    t.string   "target_type"
    t.integer  "target_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
  end

  add_index "likes", ["target_type", "target_id", "like_type"], name: "index_likes_on_target_type_and_target_id_and_like_type", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "newsarticles", force: true do |t|
    t.string   "google_news_id"
    t.string   "title"
    t.string   "url"
    t.string   "summary"
    t.datetime "date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "source"
    t.float    "popularity_score"
  end

  add_index "newsarticles", ["google_news_id", "id"], name: "index_newsarticles_on_google_news_id_and_id", using: :btree

  create_table "predictionends", force: true do |t|
    t.float    "actual_end_price"
    t.datetime "actual_end_time"
    t.boolean  "end_price_verified"
    t.integer  "prediction_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "predictionends", ["prediction_id"], name: "index_predictionends_on_prediction_id", using: :btree

  create_table "predictions", force: true do |t|
    t.integer  "user_id"
    t.float    "score"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "prediction_comment"
    t.integer  "stock_id"
    t.datetime "start_time"
    t.boolean  "start_price_verified"
    t.boolean  "active"
    t.float    "start_price"
    t.float    "popularity_score"
    t.float    "actual_end_price"
    t.datetime "actual_end_time"
    t.datetime "prediction_end_time"
    t.float    "prediction_end_price"
  end

  add_index "predictions", ["stock_id"], name: "index_predictions_on_stock_id", using: :btree
  add_index "predictions", ["user_id", "created_at"], name: "index_predictions_on_user_id_and_created_at", using: :btree
  add_index "predictions", ["user_id"], name: "index_predictions_on_user_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "stockprices", force: true do |t|
    t.string   "ticker_symbol"
    t.datetime "date"
    t.float    "open_price"
    t.float    "close_price"
    t.integer  "volume",        limit: 8
    t.integer  "split"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "stockprices", ["date"], name: "index_stockprices_on_date", using: :btree
  add_index "stockprices", ["ticker_symbol"], name: "index_stockprices_on_ticker_symbol", using: :btree

  create_table "stocks", force: true do |t|
    t.string   "stock"
    t.string   "exchange"
    t.boolean  "active"
    t.string   "ticker_symbol"
    t.datetime "date"
    t.float    "daily_percent_change"
    t.integer  "daily_volume",         limit: 8
    t.float    "price_to_earnings"
    t.float    "ytd_percent_change"
    t.float    "daily_stock_price"
    t.string   "stock_industry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stock_sector"
    t.boolean  "viewed"
  end

  add_index "stocks", ["active"], name: "index_stocks_on_active", using: :btree
  add_index "stocks", ["date"], name: "index_stocks_on_date", using: :btree
  add_index "stocks", ["exchange"], name: "index_stocks_on_exchange", using: :btree
  add_index "stocks", ["id"], name: "index_stocks_on_id", using: :btree
  add_index "stocks", ["stock_industry"], name: "index_stocks_on_stock_industry", using: :btree
  add_index "stocks", ["ticker_symbol"], name: "index_stocks_on_ticker_symbol", using: :btree
  add_index "stocks", ["updated_at"], name: "index_stocks_on_updated_at", using: :btree

  create_table "streams", force: true do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "streamable_id"
    t.string   "streamable_type"
    t.string   "target_type"
    t.string   "target_id"
  end

  add_index "streams", ["streamable_type", "streamable_id"], name: "index_streams_on_streamable_type_and_streamable_id", using: :btree
  add_index "streams", ["target_id"], name: "index_streams_on_target_id", using: :btree
  add_index "streams", ["target_type"], name: "index_streams_on_target_type", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_digest"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
