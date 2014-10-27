class FixColumnAgain < ActiveRecord::Migration
  def change
  	rename_column :newusers, :name, :username
  end
end
