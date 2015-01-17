class ChangePredictionsTable < ActiveRecord::Migration
  def change
    remove_column :predictions, :days_remaining
    add_column :predictions, :start_time, :datetime
    add_column :predictions, :start_price_verfified, :boolean
  end
end
