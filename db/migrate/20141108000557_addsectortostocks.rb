class Addsectortostocks < ActiveRecord::Migration
  def change
  	add_column :stocks, :stock_sector, :string
  end
end
