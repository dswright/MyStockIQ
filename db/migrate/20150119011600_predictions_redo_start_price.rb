class PredictionsRedoStartPrice < ActiveRecord::Migration
  def change
    remove_column :predictions, :start_price
    add_column :predictions, :start_price, :float
  end
end
