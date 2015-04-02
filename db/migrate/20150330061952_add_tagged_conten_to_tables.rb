class AddTaggedContenToTables < ActiveRecord::Migration
  def change

  	add_column :comments, :tagged_content, :string
  	add_column :predictions, :tagged_content, :string
  	add_column :newsarticles, :tagged_content, :string
  	add_column :predictionends, :tagged_content, :string

  end
end
