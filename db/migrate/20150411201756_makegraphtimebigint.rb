class Makegraphtimebigint < ActiveRecord::Migration
  def change
    remove_column :stockprices, :graph_time
    remove_column :intradayprices, :graph_time
    add_column :stockprices, :graph_time, :bigint
    add_column :intradayprices, :graph_time, :bigint
  end
end
