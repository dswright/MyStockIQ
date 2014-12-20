class AddTypeToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :type, :string
  end
end
