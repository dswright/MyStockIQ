class AddPopularityScoreToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :popularity_score, :integer
  end
end
