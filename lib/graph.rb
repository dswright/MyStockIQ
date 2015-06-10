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
  end

  def prediction #this is used for the predictiondetails graph.
    prediction = @prediction
    prediction_graph = [
      {"id":prediction.id, "x": prediction.graph_start_time, "y": prediction.start_price}, 
      {"id":prediction.id, "x": prediction.graph_end_time, "y": prediction.prediction_end_price}
    ]
    return prediction_graph
  end


  def predictionend #used for the prediction details graph.
    if @prediction.predictionend
      return [{"id": @prediction.id, "x": @prediction.graph_start_time, "y": @prediction.start_price}, 
        {"id": @prediction.id, "x": @prediction.predictionend.graph_end_time, "y": @prediction.predictionend.actual_end_price}]
    else
      return []
    end
  end

  def my_prediction
    my_prediction = []
    Prediction.where(stock_id: @stock.id, active:true, user_id: @current_user.id).each do |prediction|
      symbol = "triangle"
      if prediction.prediction_end_price < prediction.start_price
        symbol = "triangle-down"
      end

      graph_time = prediction.graph_end_time
      my_prediction << {
        "id": prediction.id, 
        "x": graph_time, 
        "y": prediction.prediction_end_price,
        marker: {
          symbol: symbol
        }
      };
    end
    return my_prediction
  end

  def predictions #predictions for the stock graph.
    predictions_array = []
    Prediction.where(stock_id: @stock.id, active:true).where('user_id not in (?)',[@current_user.id]).limit(1500).reorder('prediction_end_time desc').reverse.each do |prediction|
      symbol = "triangle"
      if prediction.prediction_end_price < prediction.start_price
        symbol = "triangle-down"
      end

      predictions_array << {
        "id": prediction.id, 
        "x": prediction.graph_end_time, 
        "y": prediction.prediction_end_price, 
        marker: {
          symbol:symbol
        }
      }
    end
    return predictions_array
  end

  #Limited to 400 5 minute periods, which is 2000 minutes, just over the 975 minutes in 5 6.5 hour days.

  def intraday_prices
    start = @start_point - 60*60*24*9 #minus 9 days from the start_time to get at least 5 days of historical intraday data.
    finish = @start_point + 60*60*24*6 #add 6 days to get at least 3 days of forward looking data.
    price_array = []
    Intradayprice.where(ticker_symbol:@ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').reverse.each do |price|    
      price_array << {"id": price.id, "x": price.graph_time, "y": price.close_price}
    end
    return price_array
  end

  #this function forms a full 5 year array. The actual control is done with the x axis settings of the graph.
  def daily_prices
    start = @start_point - 60*60*24*1825 #minus 5 years from the start_time to get 5 years of historical daily data.
    finish = @start_point + 60*60*24*950 #add 2.5 years to get 2.5 years of forward looking data.
    price_array = []
    Stockprice.where(ticker_symbol: @ticker_symbol).where("date > ?", start).where("date < ?", finish).reorder('date desc').reverse.each do |price|
      price_array << {"id": price.id, "x": price.graph_time, "y": price.close_price}
    end
    return price_array
  end

  def future_days
    start = @start_point.graph_time
    finish = start + 1095*3600*24*1000 #this is 3 years forward. (365*3)
    date_array = []
    Futureday.where("graph_time > ?", start).where("graph_time <= ?", finish).reorder('graph_time asc').each do |date|
      date_array << {"x": date.graph_time, "y":nil}
    end
    return date_array
  end

  def future_times
    start = @start_point.graph_time
    finish = start + 3*3600*24*1000 #this is 3 days forward. (24 * 3 * 60). this needs to be in real time, not interval time. Yes.
    date_array = []
    Futuretime.where("graph_time > ?", start).where("graph_time <= ?", finish).reorder('graph_time asc').each do |date|
      date_array << {"x": date.graph_time, "y":nil}
    end
    return date_array
  end
end