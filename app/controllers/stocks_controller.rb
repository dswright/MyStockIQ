class StocksController < ApplicationController
require 'stockgraph'
require 'scraper'

	
	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show

    stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])
    @ticker_symbol = params[:ticker_symbol]

		@current_user = current_user
		@stock = Stock.find(stock.id)
		#Stock's posts, comments, and predictions to be shown in the view
		streams = Stream.where(target_type: "Stock", target_id: @stock.id)
   	@stream_hash_array = Stream.stream_maker(streams, 0)

    #if a stock gets viewed, update the stocks table so that the stock gets real time stock data.
    if (@stock.viewed == false)
      days = 6
      ScraperPublic.google_intraday(@ticker_symbol, days)
      @stock.update(viewed:true)

    end

		#creates comment variable to be used to set up the comment creation form (see app/views/shared folder)
  	@comment = Comment.new
    @like = Like.new

 		#creates prediction variable to be used to set up the prediction creation form (see app/views/shared folder)
  	@prediction = @current_user.predictions.build(score: 0, active: 1, start_price: @stock.daily_stock_price, stock_id: @stock.id) 	

  	#If active prediction exists, show active prediction
  	if active_prediction_exists?(@prediction)
  		@prediction = Prediction.where(user_id: @current_user.id, stock_id: @stock.id, active: 1).first
  	end

    #Determines relationship between current user and target user
    @target = @stock


  	@comment_stream_inputs = "Stock:#{@stock.id}"
  	@prediction_stream_inputs = "Stock:#{@stock.id}"

    @prediction_landing_page = "stocks:#{@stock.ticker_symbol}"
    @comment_landing_page = "stocks:#{@stock.ticker_symbol}"
    @stream_comment_landing_page = "stocks:#{@stock.ticker_symbol}"


    #Graph functions
  	gon.ticker_symbol = @ticker_symbol
    gon.daily_price_array = StockGraph.get_daily_price_array(@ticker_symbol)


    #add one more bit of data to the end of the daily graph array, if there has been an intra-day update on the price.
    extra_last_day = CustomDate.utc_date_string_to_utc_date_number(stock.date)
    if extra_last_day > gon.daily_price_array.last[0]
      #set the during the day price to the end of the day, so that it dispalys evenly on the graph.
      eod_utc_date = CustomDate.utc_date_string_to_utc_date_number(stock.date.beginning_of_day) + 3600*16*1000 + 60*10*1000
      gon.daily_price_array << [eod_utc_date, stock.daily_stock_price]
    end

    gon.daily_forward_array = StockGraph.daily_forward_array(gon.daily_price_array.last[0])

    gon.intraday_price_array = StockGraph.get_intraday_price_array(@ticker_symbol) 
    gon.intraday_forward_array = StockGraph.intraday_forward_array(gon.intraday_price_array.last[0])  #this end of time needs to be defined. THen this array will work. 
    #may need to store this array in the loops?? Not sure how to get the end_time variable in here, and also not sure how to load the 2
    #different looking foward arrays... Just load both. Each needs it's own definition function.

  	#this gets used by the view to generate the html buttons.
  	@date_limits_array = StockGraphPublic.create_x_date_limits(gon.daily_price_array, gon.intraday_price_array)

    gon.graph_default_x_range_min = @date_limits_array[2][:x_range_min] #the 1 month settings
    gon.graph_default_x_range_max = @date_limits_array[2][:x_range_max] #the 1 month settings
    gon.graph_default_y_range_min = @date_limits_array[2][:y_range_min] #the 1 month settings

    gon.prediction_points_array = StockGraph.graph_prediction_points(stock.id)
	end
end
