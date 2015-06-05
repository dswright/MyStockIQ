class Addtimestampsfuturedays2 < ActiveRecord::Migration
  def change
    drop_table :futuredays

    create_table :futuredays do |t|

      t.timestamps null: false
    end
    add_column :futuredays, :date, :date
    add_column :futuredays, :graph_time, :bigint
  end
end
