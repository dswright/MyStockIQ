class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.text :ticker_symbol
      t.references :stream, index: true
      t.timestamps null: false
    end
    add_index :comments, [:stream_id, :created_at]
  end
end
