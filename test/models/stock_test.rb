require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  def setup
  	#calls the stocks fixture.
    @stock = stocks(:AAPL)
  end

#the test then checks to see if this is valid.
  test "should insert new stock" do
    assert_difference 'Stock.count', 1 do
    	Stock.new_stock(@stock)
  	end
  end
end
