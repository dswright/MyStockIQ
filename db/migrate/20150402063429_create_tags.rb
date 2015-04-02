class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :content
      t.references :tagable, polymorphic: true, index: :true

      t.timestamps null: false
    end

  end
end
