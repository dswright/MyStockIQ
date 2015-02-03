class CreatePredictionends < ActiveRecord::Migration
  def change
    create_table :predictionends do |t|
      t.float :actual_end_price #like or disklike
      t.datetime :actual_end_time
      t.boolean :end_price_verified
      t.belongs_to :prediction, index:true

      t.timestamps null: false
    end

    remove_column :predictions, :actual_end_price
    remove_column :predictions, :actual_end_time
    remove_column :predictions, :end_price_verified

  end
end