class NewStreamsTableStructure < ActiveRecord::Migration
  def change

    remove_column :streams, :stream_type
    remove_column :streams, :stock_id

    remove_reference :streams, :user, index:true

    add_reference :streams, :streamable, polymorphic: true, index: true

  end

end
