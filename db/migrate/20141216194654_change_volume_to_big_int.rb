class ChangeVolumeToBigInt < ActiveRecord::Migration
  def change
    change_column :stocks, :daily_volume, :integer, limit: 8
    change_column :stockprices, :volume, :integer, limit: 8
  end
end
