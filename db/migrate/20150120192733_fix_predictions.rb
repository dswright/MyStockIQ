class FixPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :actual_end_price, :float
    add_column :predictions, :actual_end_time, :datetime
    remove_column :predictions, :prediction_price
    remove_column :predictions, :end_time
    add_column :predictions, :prediction_end_time, :datetime
    add_column :predictions, :prediction_end_price, :float
  end
end
