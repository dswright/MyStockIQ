class AddSourceToNewsarticles < ActiveRecord::Migration
  def change
    add_column :newsarticles, :soruce, :string
  end
end
