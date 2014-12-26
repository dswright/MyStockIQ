class AddPredictionDateToPredictions < ActiveRecord::Migration
  def change
  	add_column :predictions, :end_date, :datetime
  end
end
