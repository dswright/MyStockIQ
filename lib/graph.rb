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

  def prediction #this is used for the predictiondetails graph.
    prediction = @prediction
    start_time = prediction.start_time.utc_time_int.graph_time_int
    end_time = prediction.prediction_end_time.utc_time_int.graph_time_int
    prediction_graph = [[start_time, prediction.start_price], [end_time, prediction.prediction_end_price]]
    return prediction_graph
  end

  def predictionend #used for the prediction details graph.
    if @prediction.predictionend
      return [[@prediction.start_time.utc_time_int.graph_time_int, @prediction.start_price], [@prediction.predictionend.actual_end_time.utc_time_int.graph_time_int, @prediction.predictionend.actual_end_price]]
    else
      return [[nil, nil]]
    end
  end

  def my_prediction
    my_prediction = []
    Prediction.where(stock_id: stock_id, active:true, user_id: @current_user.id).each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      my_prediction << [graph_time, prediction.prediction_end_price.round(2)]
    end
    if my_prediction.empty?
      my_prediction << [nil, nil]
    end
    return my_prediction
  end

  def predictions #predictions for the stock graph.
    predictions_array = []
    Prediction.where(stock_id: stock_id, active:true).where('user_id not in (?)',[@current_user.id]).limit(1500).reorder('prediction_end_time desc').reverse.each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      predictions_array << [graph_time, prediction.prediction_end_price.round(2)]
    end
    return predictions_array
  end

  def prediction_ids
    prediction_ids_array = []
    Prediction.where(stock_id: stock_id, active:true).where('user_id not in (?)',[@current_user.id]).limit(1500).reorder('prediction_end_time desc').reverse.each do |prediction|
      prediction_ids_array << prediction.id
    end
    return prediction_ids_array
  end

  def my_prediction_id
    my_prediction_id_array = []
    Prediction.where(stock_id: stock_id, active:true, user_id: @current_user.id).each do |prediction|
      my_prediction_id_array << prediction.id
    end
    if my_prediction_id_array.empty?
      my_prediction_id_array << nil
    end
    return my_prediction_id_array
  end

  #Limited to 400 5 minute periods, which is 2000 minutes, just over the 975 minutes in 5 6.5 hour days.

  def intraday_prices
    price_array = []
    Intradayprice.where(ticker_symbol:self.ticker_symbol).limit(400).reorder('date desc').reverse.each do |price|    
      graph_time = price.date.utc_time_int.graph_time_int
      price_array << [graph_time, price.close_price.round(2)]
    end
    return price_array
  end

  #this function forms a full 5 year array. The actual control is done with the x axis settings of the graph.
  def daily_prices
    price_array = []
    Stockprice.where(ticker_symbol: self.ticker_symbol).limit(1300).reorder('date desc').each do |price|
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
end