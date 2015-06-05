class Renamefuturetimes < ActiveRecord::Migration
  def change
    change_column :futuretimes, :time, :datetime
  end
end
