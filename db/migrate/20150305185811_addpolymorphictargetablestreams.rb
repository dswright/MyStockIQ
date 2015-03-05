class Addpolymorphictargetablestreams < ActiveRecord::Migration
  def change
    add_reference :streams, :targetable, polymorphic: true, index: true
  end
end
