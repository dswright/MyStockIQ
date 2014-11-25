class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.text :content
      t.references :user, index: true

      t.timestamps null: false
    end
    add_index :streams, [:user_id, :created_at]
  end
end
