class Adddailychangetodailyprices < ActiveRecord::Migration
  def change
    add_column :stockprices, :daily_percent_change, :float
  end
end
