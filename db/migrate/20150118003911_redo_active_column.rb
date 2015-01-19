class RedoActiveColumn < ActiveRecord::Migration


  def change
    remove_column :predictions, :active
    add_column :predictions, :active, :boolean
  end


end
