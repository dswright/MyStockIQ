class Dropstreamcolumns < ActiveRecord::Migration
  def change
    remove_column :streams, :target_id
    remove_column :streams, :target_type
  end
end
