class AddRememberDigestToNewusers < ActiveRecord::Migration
  def change
    add_column :newusers, :remember_digest, :string
  end
end
