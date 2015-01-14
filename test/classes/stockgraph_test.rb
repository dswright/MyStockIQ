require 'test_helper'
require 'customdate'
require 'stockgraph'

class StockgraphTest < ActiveSupport::TestCase

  #gets an array of all daily data points from the stockprices table. LNKD should have more than 500.

   test "get daily price array" do
    price_array = StockGraph.get_daily_price_array("LNKD")
    #the fixture defines the stockprice values, which are then converted to utc time in the stock graph 
    #function and checked here.
    assert price_array == [[1420761600000, 200], [1420848000000, 150]]
  end

  test "start time for day" do
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-20 12:30:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    opening_time = StockGraph.start_time_for_day(utc_date_number, -3)
    assert opening_time == 1421487000000
  end

  test "end time for day" do
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-20 12:30:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    closing_time = StockGraph.end_time_for_day(utc_date_number, 0)
    assert closing_time == 1421769600000
  end

  test "find y min" do
    price_array = StockGraph.get_daily_price_array("LNKD")
    #these date times are 2015-01-08 and 2015-01-11
    min_price = StockGraph.find_y_min(price_array, 1420675200000, 1420934400000)
    assert min_price == 150
  end

  test "get intraday price array" do
    price_array = StockGraph.get_intraday_price_array("LNKD")
    #the fixture defines the stockprice values, which are then converted to utc time in the stock graph 
    #function and checked here.
    assert price_array == [[1420709400000, 150], [1420709700000, 200], [1420710000000, 250]]
  end

  test "intraday forward array" do
    end_time = 1420709400000 #9:30 in the morning, January 8th 2015.
    intraday_forward_array = StockGraph.intraday_forward_array(end_time)
    assert intraday_forward_array[0] == [1420709400000, nil]
    assert intraday_forward_array.last == [1421078400000, nil]
  end
end
