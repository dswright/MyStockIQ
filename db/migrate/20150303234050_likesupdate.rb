class Likesupdate < ActiveRecord::Migration
  def change
    remove_column :likes, :target_type
    remove_column :likes, :target_id
    add_reference :likes, :likable, polymorphic: true, index: true
  end
end
