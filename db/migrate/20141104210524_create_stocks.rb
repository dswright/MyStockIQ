class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|

    	t.string 		:stock
    	t.string 		:exchange
    	t.boolean		:active
    	t.string 		:ticker_symbol
    	t.datetime 	:date
    	t.float			:daily_percent_change
    	t.integer		:daily_volume
    	t.float			:price_to_earnings
    	t.float			:ytd_percent_change
    	t.float			:daily_stock_price
    	t.string		:stock_industry

      t.timestamps
    end
  end
end
