class StreamAdditions < ActiveRecord::Migration
  def change
    add_column :streams, :target_type, :string
    add_column :streams, :target_id, :string
    add_index  :streams, :target_id
    add_index  :streams, :target_type

  end
end
