class FixColumnName < ActiveRecord::Migration
  def change
  	rename_column :newusers, :username, :name
  end
end
