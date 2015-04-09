class ChangeNameToContent < ActiveRecord::Migration
  def change
  	rename_column :predictions, :prediction_comment, :content
  	rename_column :predictionends, :comment, :content
  end
end
