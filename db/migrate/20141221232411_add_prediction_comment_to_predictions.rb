class AddPredictionCommentToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :prediction_comment, :string
  end
end
