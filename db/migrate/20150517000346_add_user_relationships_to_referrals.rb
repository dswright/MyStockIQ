class AddUserRelationshipsToReferrals < ActiveRecord::Migration
  def change

  	add_column :referrals, :inviter_id, :integer
  	add_column :referrals, :invited_id, :integer

  	add_index :referrals, :inviter_id
  	add_index :referrals, :invited_id
  end
end
