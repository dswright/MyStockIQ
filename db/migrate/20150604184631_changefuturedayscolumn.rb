class Changefuturedayscolumn < ActiveRecord::Migration
  def change
    change_column :futuredays, :date, :datetime
  end
end
