class AddViewedToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :viewed, :boolean
  end
end
