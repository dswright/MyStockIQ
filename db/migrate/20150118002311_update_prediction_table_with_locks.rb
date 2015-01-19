class UpdatePredictionTableWithLocks < ActiveRecord::Migration

  def down
    change_column :predictions, :active, :integer
  end

  def up
    change_column :predictions, :active, :boolean
  end

  def change
    add_column :predictions, :end_price_verified, :boolean
    rename_column :predictions, :start_price_verfified, :start_price_verified
  end
end
