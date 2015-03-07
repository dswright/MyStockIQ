class AddRepliableToReplies < ActiveRecord::Migration
  def change
  	add_reference :replies, :repliable, polymorphic: true, index: true
  end
end
