class Addendingcommenttoprediction < ActiveRecord::Migration
  def change
    add_column :predictionends, :comment, :string
  end
end
