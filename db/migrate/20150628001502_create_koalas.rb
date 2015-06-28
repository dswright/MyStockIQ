class CreateKoalas < ActiveRecord::Migration
  def change
    create_table :koalas do |t|
      t.string :name
      t.string :color

      t.timestamps null: false
    end
  end
end
