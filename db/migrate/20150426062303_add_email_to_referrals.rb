class AddEmailToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :email, :string
  end
end
