class AddIndexToUsersUsername < ActiveRecord::Migration
  def change
  	add_index :newusers, :username, unique: true
  end
end
