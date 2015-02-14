class Graph
  require 'customdate'
  require 'sessions_helper'
  include SessionsHelper

  attr_reader :ticker_symbol, :stock_id
  
  GraphPoint = Struct.new(:graph_time, :stock_price)

  #settings is a hash of parameters passed from the controller. 
  #It takes ticker, current user, and more settings.
  def initialize(settings = {})
    @ticker_symbol = settings[:ticker_symbol]
    @stock_id = Stock.find_by(ticker_symbol: @ticker_symbol)
    @current_user = settings[:current_user]

    @prediction = settings[:prediction] #this is passed by the prediction details graph.

  end

  def my_prediction
    my_prediction = []
    Prediction.where(stock_id: stock_id, active:true, user_id: @current_user.id).each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      my_prediction << [graph_time, prediction.prediction_end_price.round(2)]
    end
    if my_prediction.empty?
      my_prediction << [0, nil]
    end
    return my_prediction
  end

  def prediction
    prediction = @prediction
    start_time = prediction.start_time.utc_time_int.graph_time_int
    end_time = prediction.prediction_end_time.utc_time_int.graph_time_int
    prediction_graph = [[start_time, prediction.start_price], [end_time, prediction.prediction_end_price]]
    return prediction_graph
  end


  def predictions
    predictions = []
    Prediction.where(stock_id: stock_id, active:true).where('user_id not in (?)', [@current_user.id]).limit(1500).order('prediction_end_time desc').reverse.each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      predictions << [graph_time, prediction.prediction_end_price.round(2)]
    end
    return predictions
  end

  #Limited to 400 5 minute periods, which is 2000 minutes, just over the 975 minutes in 5 6.5 hour days.

  def intraday_prices
    price_array = []
    stock_prices = Intradayprice.where(ticker_symbol:self.ticker_symbol).limit(400).order('date desc').reverse.each do |price|    
      graph_time = price.date.utc_time_int.graph_time_int
      price_array << [graph_time, price.close_price.round(2)]
    end
    return price_array
  end

  #this function forms a full 5 year array. The actual control is done with the x axis settings of the graph.
  def daily_prices
    stock_prices = Stockprice.where(ticker_symbol: ticker_symbol).limit(1300).order('date desc') 
    price_array = []
    stock_prices.each do |price|
      graph_time = price.date.utc_time_int.graph_time_int #these methods will no longer be available... the database will send a date time stamp over the json api...
      price_array << [graph_time, price.close_price.round(2)]
    end
    price_array.reverse!

    stock = Stock.find_by(ticker_symbol: ticker_symbol)
    extra_day = stock.date.utc_time_int.graph_time_int
    if extra_day > price_array.last[0]
      extra_day = extra_day.utc_time_int.utc_time.beginning_of_day.strftime("%Y-%m-%d 21:00:00").utc_time.utc_time_int.graph_time_int
      price_array << [extra_day, stock.daily_stock_price.round(2)]
    end
    return price_array
  end

  #returns an array of time time and price variables.
  #used to look into the future on the graph.
  #intraday forward array currently looks ahead 3 days arbitrarily. The exact ahead time would be 2.5 days.
  #The actual target setting is controlled with the x axis settings.
  def intraday_forward_prices
    forward_array_start = intraday_prices.last[0]
    forward_array = []
    i = 0;
    iterations = 390 # 5 6.5 hour days of 5 minute iterations. 5 days is necessary to generate the prediction details graph.
    while i<=iterations do
      time_spot = forward_array_start + i*5*60*1000
      if time_spot.utc_time_int.valid_stock_time?
        forward_array << [time_spot, nil]
      else
        iterations += 1
      end
      i += 1
    end
    return forward_array
  end

  #end time is assumed to be an est number.
  #the graph start time int is the end of the actual data array.
  #whether that be the daily array or the intraday array, it gets the last day of data..
  def daily_forward_prices
    forward_array_start = self.daily_prices.last[0]
    i = 1;
    forward_array = []
    iterations = 1202  #its now a 5 year look forward period. 1200 days estimates 240 days per year.
    while i<=iterations do
      time_spot = forward_array_start + i*24*3600*1000
      if time_spot.utc_time_int.valid_stock_time? #adjust the est time to utc time for confirmation.
        forward_array << [time_spot, nil]
      else
        iterations += 1
      end
      i += 1
    end
    return forward_array
  end
end

=begin

  RangeSetting = Struct.new(:time_interval, :time_length, :predictions, :prices)
  ButtonSetting = Struct.new(:name, :start, :settings)

  def ranges
    intraday_settings = RangeSetting.new(60*5*1000, 6.5*3600*1000.to_i, predictions+my_prediction, intraday_prices)
    daily_settings = RangeSetting.new(24*3600*1000, 24*3600*1000.to_i, predictions+my_prediction, daily_prices)
    buttons = [ButtonSetting.new("1d", 1, intraday_settings), 
                ButtonSetting.new("5d", 5, intraday_settings),
                ButtonSetting.new("1m", 20, daily_settings),
                ButtonSetting.new("3m", 60, daily_settings),
                ButtonSetting.new("6m", 120, daily_settings),
                ButtonSetting.new("1yr", 240, daily_settings),
                ButtonSetting.new("5yr", 1200, daily_settings)
              ]

    ranges = []
    buttons.each do |button|
      button = Button.new(button)
      ranges << {name: button.buttonsetting.name,
                          x_range_min: button.start_time, 
                          x_range_max: button.end_time,
                          y_range_min: button.y_min,
                          y_range_max: button.y_max
                        }
    end
    return ranges
  end
end


class Button

  attr_reader :buttonsetting, :start_time, :end_time, :limited_prices, :limited_predictions
  
  def initialize(buttonsetting)
    @buttonsetting = buttonsetting
    @start_time = end_point(-1)
    @end_time = end_point(1)
    @limited_prices = limited_array(buttonsetting.settings.prices)
    @limited_predictions = limited_array(buttonsetting.settings.predictions)
  end

  #returns the nearest valid start or end point. -1 interval direction is to get start point, 1 is to get endpoint.
  def end_point(interval_direction)
    last_utc_time_int = @buttonsetting.settings.prices.last[0]
    #time_length is used to calculate the number of iterations..
    time_length = buttonsetting.settings.time_length * buttonsetting.start
    time_length /= 2 if interval_direction == 1 #if looking forward, cut the time length in half.
    interval = buttonsetting.settings.time_interval
    i=0
    iterations = time_length/interval
    while i<=iterations do
      time_to_check = (last_utc_time_int + i*interval*interval_direction).to_i.utc_time_int
      unless time_to_check.valid_stock_time?
        iterations += 1
      end
      i+=1
    end
    end_time = last_utc_time_int + interval*iterations*interval_direction
    return end_time
  end

  def limited_array(graph_array)
    graph_array.select{|point| point[0] >= @start_time && point[0] <= @end_time}
  end

  def y_min
    min_price = limited_prices.min_by {|point| point[1]}[1]
    min_price_final = min_price
    limited_predictions.each do |point|
      if point[1] < min_price_final
        if point[1] > min_price * 0.4
          min_price_final = point[1] * 0.95
        end
      end
    end
    return min_price_final
  end

  def y_max
    max_price = limited_prices.max_by {|point| point[1]}[1]
    max_price_final = max_price
    limited_predictions.each do |point|
      if point[1] > max_price_final
        if point[1] < max_price * 2.5
          max_price_final = point[1] * 1.05
        end
      end
    end
    return max_price_final
  end
end
=end
