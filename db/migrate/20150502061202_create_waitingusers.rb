class CreateWaitingusers < ActiveRecord::Migration
  def change
    create_table :waitingusers do |t|

      t.string :email

      t.timestamps null: false
    end
    add_index :waitingusers, :email
  end
end
