class Addindextodate < ActiveRecord::Migration
  def change
    add_index :stocks, :date
    add_index :stocks, :updated_at
    add_index :stocks, :id
    add_index :stocks, :exchange
    add_index :stocks, :stock_industry
  end
end
