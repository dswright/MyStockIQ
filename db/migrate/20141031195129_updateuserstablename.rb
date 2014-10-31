class Updateuserstablename < ActiveRecord::Migration
  def change
  	rename_table :newusers, :users
  end
end
