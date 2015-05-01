class Addinggraphtimetopredictionandpredictionends < ActiveRecord::Migration
  def change
    add_column :predictions, :graph_start_time, :bigint
    add_column :predictions, :graph_end_time, :bigint
    add_column :predictionends, :graph_end_time, :bigint
  end
end
