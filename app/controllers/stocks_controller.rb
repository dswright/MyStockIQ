class StocksController < ApplicationController
require 'graph'
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

    streams.each {|stream| stream.streamable.update_popularity_score}
    streams = sort_by_popularity(streams)
    streams = streams.reverse

    unless streams == nil
      @stream_hash_array = Stream.stream_maker(streams, 0)
    end



    

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
  	if @prediction.active_prediction_exists?
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

    graph = Graph.new(@ticker_symbol)

  	gon.ticker_symbol = @ticker_symbol
    gon.daily_prices = graph.daily_prices
    gon.daily_forward_prices = graph.daily_forward_prices
    gon.intraday_prices = graph.intraday_prices
    gon.intraday_forward_prices = graph.intraday_forward_prices
    gon.predictions = graph.predictions
    
    #used by the view to generate the html buttons
    @graph_ranges = graph.ranges


    gon.graph_defaults = @graph_ranges[2]

	end
end
