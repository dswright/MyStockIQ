class ChangePopularityScoreFormat < ActiveRecord::Migration
  def up
  	change_column :comments, :popularity_score, :float
  	change_column :predictions, :popularity_score, :float
  end

  def down
  	change_column :comments, :popularity_score, :integer
  	change_column :predictions, :popularity_score, :integer
  end
end
