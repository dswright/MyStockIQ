class Graph
  require 'customdate'
  require 'sessions_helper'
  include SessionsHelper
  
  GraphPoint = Struct.new(:graph_time, :stock_price)

  #settings is a hash of parameters passed from the controller. 
  #It takes ticker, current user, and more settings.
  def initialize(settings = {})
    @ticker_symbol = settings[:ticker_symbol]
    @current_user = settings[:current_user]
    @stock = Stock.find_by(ticker_symbol:@ticker_symbol)

    @prediction = settings[:prediction] #this is passed by the prediction details graph.

    #the start point for the different graphs is different because they are anchored in different points in time.
    if settings[:start_point] == "stocks"
      @start_point = Stock.find_by(ticker_symbol:@ticker_symbol).date
    elsif settings[:start_point] == "predictiondetails"
      @start_point = @prediction.start_time
    end
    #@last_daily_date = daily_prices[-2][0] #get the last id from the dailyprices array..
  end

  def prediction #this is used for the predictiondetails graph.
    prediction = @prediction
    start_time = prediction.start_time.utc_time_int.graph_time_int
    end_time = prediction.prediction_end_time.utc_time_int.graph_time_int
    prediction_graph = [[start_time, prediction.start_price], [end_time, prediction.prediction_end_price]]
    return prediction_graph
  end

  def prediction_details_id #used for the prediction details graph.
    return @prediction.id
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
    Prediction.where(stock_id: @stock.id, active:true, user_id: @current_user.id).each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      my_prediction << [graph_time, prediction.prediction_end_price]
    end
    if my_prediction.empty?
      my_prediction << [nil, nil]
    end
    return my_prediction
  end

  def predictions #predictions for the stock graph.
    predictions_array = []
    Prediction.where(stock_id: @stock.id, active:true).where('user_id not in (?)',[@current_user.id]).limit(1500).reorder('prediction_end_time desc').reverse.each do |prediction|
      graph_time = prediction.prediction_end_time.utc_time_int.graph_time_int
      predictions_array << [graph_time, prediction.prediction_end_price]
    end
    return predictions_array
  end

  def prediction_ids
    prediction_ids_array = []
    Prediction.where(stock_id: @stock.id, active:true).where('user_id not in (?)',[@current_user.id]).limit(1500).reorder('prediction_end_time desc').reverse.each do |prediction|
      prediction_ids_array << prediction.id
    end
    return prediction_ids_array
  end

  def my_prediction_id
    my_prediction_id_array = []
    Prediction.where(stock_id: @stock.id, active:true, user_id: @current_user.id).each do |prediction|
      my_prediction_id_array << prediction.id
    end
    if my_prediction_id_array.empty?
      my_prediction_id_array << nil
    end
    return my_prediction_id_array
  end

  def daily_price_ids #last_date is in graphtime.
    daily_price_id_array = []
    start = @start_point - 60*60*24*1825 #minus 5 years from the start_time to get 5 years of historical daily data.
    finish = @start_point + 60*60*24*950 #add 2.5 years to get 2.5 years of forward looking data.
    Stockprice.where(ticker_symbol: @ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').each do |price|
      daily_price_id_array << price.id
    end
    daily_price_id_array.reverse!

    #stock = Stock.find_by(ticker_symbol: @ticker_symbol)
    #if @last_daily_date < stock.date.utc_time_int.graph_time_int
    #  daily_price_id_array << @ticker_symbol
    #end
    #return daily_price_id_array
  end

  def intraday_price_ids
    start = @start_point - 60*60*24*9 #minus 9 days from the start_time to get at least 5 days of historical intraday data.
    finish = @start_point + 60*60*24*6 #add 6 days to get at least 3 days of forward looking data.
    intraday_price_ids = []
    Intradayprice.where(ticker_symbol:@ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').reverse.each do |price|    
      intraday_price_ids << price.id
    end
    return intraday_price_ids
  end


  #Limited to 400 5 minute periods, which is 2000 minutes, just over the 975 minutes in 5 6.5 hour days.

  def intraday_prices
    start = @start_point - 60*60*24*9 #minus 9 days from the start_time to get at least 5 days of historical intraday data.
    finish = @start_point + 60*60*24*6 #add 6 days to get at least 3 days of forward looking data.
    price_array = []
    Intradayprice.where(ticker_symbol:@ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').reverse.each do |price|    
      price_array << [price.graph_time, price.close_price]
    end
    return price_array
  end

  #this function forms a full 5 year array. The actual control is done with the x axis settings of the graph.
  def daily_prices
    start = @start_point - 60*60*24*1825 #minus 5 years from the start_time to get 5 years of historical daily data.
    finish = @start_point + 60*60*24*950 #add 2.5 years to get 2.5 years of forward looking data.
    price_array = []
    Stockprice.where(ticker_symbol: @ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').each do |price|
      price_array << {"id": price.id, "x": price.graph_time, "y": price.close_price}
      #price_array << [price.graph_time, price.close_price]
    end
    price_array.reverse!

    # stock = Stock.find_by(ticker_symbol: @ticker_symbol)
    # extra_day = stock.date.utc_time_int.graph_time_int
    # if price_array.last[0] < extra_day
    #   extra_day = extra_day.utc_time_int.utc_time.beginning_of_day.strftime("%Y-%m-%d 21:00:00").utc_time.utc_time_int.graph_time_int
    #   price_array << [extra_day, stock.daily_stock_price]
    # end
    return price_array
  end
end