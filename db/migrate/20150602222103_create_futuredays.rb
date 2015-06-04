class CreateFuturedays < ActiveRecord::Migration
  def change
    create_table :futuredays do |t|
    end
    add_column :futuredays, :day, :date
    add_column :futuredays, :graph_time, :bigint
  end
end
