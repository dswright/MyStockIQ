class CreatePopularities < ActiveRecord::Migration
  def change
    create_table :popularities do |t|

      t.timestamps null: false
    end

    add_column :popularities, :score, :float
    add_reference :popularities, :popularable, polymorphic: true, index: true

  end
end
