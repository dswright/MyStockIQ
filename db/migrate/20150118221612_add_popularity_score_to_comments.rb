class AddPopularityScoreToComments < ActiveRecord::Migration
  def change
    add_column :comments, :popularity_score, :integer
  end
end
