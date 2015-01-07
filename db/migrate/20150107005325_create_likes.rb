class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :like_type #like or disklike
      t.string :target_type
      t.integer :target_id

      t.timestamps null: false
    end
    add_index :likes, [:target_type, :target_id, :like_type]
    add_reference :likes, :user, index: true

  end
end
