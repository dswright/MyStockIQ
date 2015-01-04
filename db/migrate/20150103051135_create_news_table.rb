class CreateNewsTable < ActiveRecord::Migration
  def change
    create_table :newsarticles do |t|
      t.string :google_news_id
      t.string :ticker_symbol
      t.string :title
      t.string :url
      t.string :summary
      t.datetime :date


      t.timestamps null: false
    end
    add_index :newsarticles, [:google_news_id, :id]
  end
end
