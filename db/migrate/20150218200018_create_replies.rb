class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :content
      t.float :popularity_score
      t.references :user, index: true
      t.timestamps null: false
    end

    add_index :replies, [:user_id, :created_at]
  end
end
