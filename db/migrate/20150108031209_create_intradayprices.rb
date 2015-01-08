class CreateIntradayprices < ActiveRecord::Migration
  def change
    create_table :intradayprices do |t|
      t.string :ticker_symbol
      t.datetime :date
      t.float :open_price
      t.float :close_price

      t.timestamps null: false
    end
    add_index :intradayprices, :date
    add_index :intradayprices, :ticker_symbol
  end
end

