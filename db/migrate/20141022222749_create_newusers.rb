class CreateNewusers < ActiveRecord::Migration
  def change
    create_table :newusers do |t|
      t.string :username
      t.string :email

      t.timestamps
    end
  end
end
