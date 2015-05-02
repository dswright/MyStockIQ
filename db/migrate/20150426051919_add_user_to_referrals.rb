class AddUserToReferrals < ActiveRecord::Migration
  def change
    add_reference :referrals, :user, index: true
  end
end
