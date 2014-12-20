class AddTickerSymbolToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :ticker_symbol, :string
  end
end
