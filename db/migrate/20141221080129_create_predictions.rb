class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.float :prediction_price
      t.references :user, index: true
      t.references :stock, index: true
      t.float :score
      
      t.timestamps null: false
    end
    add_index :predictions, [:user_id, :created_at]
    add_index :predictions, [:stock_id, :created_at]
  end
end
