class AddPredictionCountToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :active_predictions, :integer, default: 0
  end
end
