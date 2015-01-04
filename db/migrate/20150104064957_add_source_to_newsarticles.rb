class AddSourceToNewsarticles < ActiveRecord::Migration
  def change
    remove_column :newsarticles, :soruce, :string
    add_column :newsarticles, :source, :string
  end
end
