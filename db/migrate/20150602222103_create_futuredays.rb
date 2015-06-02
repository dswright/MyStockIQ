class CreateFuturedays < ActiveRecord::Migration
  def change
    create_table :futuredays do |t|

      t.timestamps null: false
    end
  end
end
