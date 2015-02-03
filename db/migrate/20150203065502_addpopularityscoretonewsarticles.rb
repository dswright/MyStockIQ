class Addpopularityscoretonewsarticles < ActiveRecord::Migration
  def change
    add_column :newsarticles, :popularity_scores, :float
  end
end
