class CreateFuturetimes < ActiveRecord::Migration
  def change
    create_table :futuretimes do |t|

      t.timestamps null: false
    end
    add_column :futuretimes, :time, :date
    add_column :futuretimes, :graph_time, :bigint
  end
end
