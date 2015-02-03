class Addpopularitytoendpredictions < ActiveRecord::Migration
  def change
    add_column :predictionends, :popularity_score, :float
  end
end
