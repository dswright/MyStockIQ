class AddIndexActivetickerDate < ActiveRecord::Migration
  def change
    add_index :stockprices, :ticker_symbol
    add_index :stockprices, :date
    add_index :stocks, :active
    add_index :stocks, :ticker_symbol
  end
end
