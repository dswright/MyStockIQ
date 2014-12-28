class AddColumnstoPredictions < ActiveRecord::Migration
  def change
  	add_column :predictions, :active, :integer
  	add_column :predictions, :days_remaining, :decimal
  	add_column :predictions, :start_price, :decimal
  	
  end
end
