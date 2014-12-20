class RemoveTickerSymbolFromStreams < ActiveRecord::Migration
  def change
    remove_column :streams, :ticker_symbol, :string
  end
end
