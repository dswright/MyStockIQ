class Removepopularityscorecolumn < ActiveRecord::Migration
  def change
    remove_column :newsarticles, :popularity_score
    remove_column :comments, :popularity_score
    remove_column :predictions, :popularity_score
    remove_column :predictionends, :popularity_score
  end
end
