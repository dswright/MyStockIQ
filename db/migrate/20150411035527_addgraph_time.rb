class AddgraphTime < ActiveRecord::Migration
  def change
    add_column :stocks, :graph_time, :integer
    add_column :intradayprices, :graph_time, :integer
  end
end
