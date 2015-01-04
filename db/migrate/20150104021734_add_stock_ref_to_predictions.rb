class AddStockRefToPredictions < ActiveRecord::Migration
  def change
    add_reference :predictions, :stock, index: true
  end
end
