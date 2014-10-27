class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
  	add_index :newusers, :email, unique: true
  end
end
