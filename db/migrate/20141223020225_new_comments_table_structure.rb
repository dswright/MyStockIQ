class NewCommentsTableStructure < ActiveRecord::Migration
  def change

    remove_column :comments, :ticker_symbol
    remove_reference :comments, :stream, index:true
    add_reference :comments, :user, index: true

  end
end
