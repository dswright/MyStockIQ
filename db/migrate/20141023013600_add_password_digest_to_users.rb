class AddPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :newusers, :password_digest, :string
  end
end
