class RemoveTickerFromNews < ActiveRecord::Migration
  def change
    remove_column :newsarticles, :ticker_symbol
  end
end
