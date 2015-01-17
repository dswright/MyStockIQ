class ChangeNameOfEndDate < ActiveRecord::Migration
  def change
    rename_column :predictions, :end_date, :end_time

  end
end
