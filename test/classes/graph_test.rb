require 'test_helper'
require 'customdate'
require 'graph'

class GraphTest < ActiveSupport::TestCase

  #gets an array of all daily data points from the stockprices table. LNKD should have more than 500.

  def setup
    @graph = Graph.new("LNKD")
    daily_settings = Graph::RangeSetting.new(24*3600*1000, 24*3600*1000.to_i, @graph.predictions, @graph.daily_prices)
    button_settings = Graph::ButtonSetting.new("1m", 20, daily_settings)
    @button = Button.new(button_settings)
  end

  test "daily prices" do
    #the fixture defines the stockprice values, which are then converted to utc time in the stock graph 
    #function and checked here.
    #the last element of this array is the latest daily price from the stocks fixture.
    assert @graph.daily_prices == [[1420732800000, 150.0],[1420819200000, 200.0], [1421078400000, 100.0]]
  end

  test "intraday prices" do
    #the fixture defines the stockprice values, which are then converted to utc time in the stock graph 
    #function and checked here.
    assert @graph.intraday_prices == [["2015-01-08 14:30:00".utc_time.utc_time_int.graph_time_int, 150], 
                                      ["2015-01-08 14:35:00".utc_time.utc_time_int.graph_time_int, 200], 
                                      ["2015-01-08 14:40:00".utc_time.utc_time_int.graph_time_int, 250]]
                                     
  end

  test "predictions" do
    assert @graph.predictions == [[1422028800000, 110], [1422288000000, 120]]
  end

  test "intraday forward prices" do
    #check to make sure that the final day of the forward array is exactly 3 days ahead of the last intradayprice 
    assert @graph.intraday_forward_prices.last == ["2015-01-13 14:35:00".utc_time.utc_time_int.graph_time_int, nil]
  end

  test "daily forward prices" do
    #check to make sure that the final day of the forward array is 602 days ahead of the last intradayprice 
    assert @graph.daily_forward_prices.last == ["2017-06-08 21:00:00".utc_time.utc_time_int.graph_time_int, nil]
  end

  test "graph ranges" do
    assert @graph.ranges.last[:name] == "5yr"
    assert @graph.ranges.last[:x_range_min] == "2010-03-24 21:00:00".utc_time.utc_time_int.graph_time_int
    assert @graph.ranges.last[:x_range_max] == "2017-06-06 21:00:00".utc_time.utc_time_int.graph_time_int
    assert @graph.ranges.last[:y_range_min] == 100
    assert @graph.ranges.last[:y_range_max] == 200
  end

  #test "end point" do
  #  puts @button.end_point(-1).utc_time_int.utc_time
    #assert @button.end_point(1) == "2015-01-08 17:55:00".utc_time.utc_time_int.graph_time_int #looks 3.25 hours after the start point..
    
    #assert @button.end_point(-1) == "2015-01-07 14:45:00".utc_time.utc_time_int.graph_time_int #looks 3.25 hours after the start point..

  #end

=begin

  test "y max" do
    price_array = StockGraph.graph_daily_price_array("LNKD")
    #these date times are 2015-01-08 and 2015-01-11, which surrounds the datetimes in the fixtures
    min_price = StockGraph.find_y_min(price_array, 1420675200000, 1420934400000)
    assert min_price == 200
  end

  test "valid end point" do
    #CustomDate.valid_end_point(utc_start_time_int, interval, length_of_time)
    utc_start_time_int = "2015-01-02 20:00:00".utc_time.utc_time_int
    assert CustomDate.valid_end_point(utc_start_time_int, 24*3600, 2*24*3600).utc_time == "2015-01-06 20:00:00"

    utc_start_time_int = "2015-01-02 20:00:00".utc_time.utc_time_int
    assert CustomDate.valid_end_point(utc_start_time_int, 60*5, 60*5*5).utc_time == "2015-01-02 20:25:00"
  end

  test "valid start point" do
    #CustomDate.valid_end_point(utc_start_time_int, interval, length_of_time)
    utc_start_time_int = "2015-01-07 20:00:00".utc_time.utc_time_int
    assert CustomDate.valid_start_point(utc_start_time_int, 24*3600, 2*24*3600).utc_time == "2015-01-05 20:00:00"

    utc_start_time_int = "2015-01-07 20:00:00".utc_time.utc_time_int
    assert CustomDate.valid_start_point(utc_start_time_int, 60*5, 60*5*5).utc_time == "2015-01-07 19:35:00"
  end

=end
end
