class RemoveContentFromStreams < ActiveRecord::Migration
  def change
    remove_column :streams, :content, :string
  end
end
