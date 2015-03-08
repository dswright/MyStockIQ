class RemovePopularityScoreFromAll < ActiveRecord::Migration
  def change
  	remove_column :replies, :popularity_score, :float
  end
end
