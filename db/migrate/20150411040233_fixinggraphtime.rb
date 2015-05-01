class Fixinggraphtime < ActiveRecord::Migration
  def change
    add_column :stockprices, :graph_time, :integer
    remove_column :stocks, :graph_time
  end
end
