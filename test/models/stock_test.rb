require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  def setup
  	@stock = {
	  	"code" => "blah",
	    "name" => "blah inc"
  	}
    #this should sucessfully update because BNNY exists in both the industries list and is in the db.
    @successful_inserted_stock_array = [
      {ticker_symbol:"BNNY", stock:"Annies inc", stock_industry: nil, price_to_earnings: nil}
    ]
  end

#the test then checks to see if this is valid.
  test "should insert new stock" do
    assert_difference 'Stock.count', 1 do
    	Stock.new_stock(@stock)
  	end
  end

  #the first row of the quandl data is the DFVL stock
  test "should return 1st page of quandl stocktickers" do
    stock_array = Stock.get_quandl_data(1,0)
    assert_not stock_array.empty?
    assert stock_array[0]["code"] == "DFVL"
  end

  test "should return array with tickers and related industries" do
    stock_array = Stock.fetch_industry_array
    assert_not stock_array.empty?
    assert stock_array[0][:ticker_symbol] == "A"
  end

  test "should return array with industry list" do
    industry_update_array = Stock.return_industry_array(@successful_inserted_stock_array)
    assert_not industry_update_array.empty?
    assert industry_update_array[0][:stock_industry] == "Retail Store"
  end

  test "should return array with pe ratio" do
    pe_update_array = Stock.fetch_pe(@successful_inserted_stock_array)
    assert_not pe_update_array[0][:price_to_earnings].empty?

  end




end


