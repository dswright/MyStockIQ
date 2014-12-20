class AddTickerIdToStreams < ActiveRecord::Migration
  def change
    add_reference :streams, :stock, index: true
  end
end
