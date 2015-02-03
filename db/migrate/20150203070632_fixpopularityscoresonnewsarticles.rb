class Fixpopularityscoresonnewsarticles < ActiveRecord::Migration
  def change
        add_column :newsarticles, :popularity_score, :float
        remove_column :newsarticles, :popularity_scores
  end
end
