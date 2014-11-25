class CreateStockprices < ActiveRecord::Migration
  def change
    create_table :stockprices do |t|
      
      t.string    :ticker_symbol
      t.datetime  :date
      t.float     :open_price
      t.float     :close_price
      t.integer   :volume
      t.integer   :split

      t.timestamps null: false
    end
  end
end
