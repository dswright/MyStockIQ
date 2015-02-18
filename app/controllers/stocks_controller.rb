class StocksController < ApplicationController
require 'graph'
require 'scraper'
	
	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show

    @stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])

		@current_user = current_user

		#Stock's posts, comments, and predictions to be shown in the view
    #will_paginate in view automatically generates params[:page]
		@streams = Stream.where(target_type: "Stock", target_id: @stock.id)


    unless @streams == nil
      @streams.each {|stream| stream.update_stream_popularity_scores}
    end


    #this line makes sorts the stream by popularity score.
    @streams = @streams.sort_by {|stream| stream.streamable.popularity_score}
    #streams = sort_by_popularity(streams)
    @streams = @streams.reverse

    unless @streams == nil
      @stream_hash_array = Stream.stream_maker(@streams, 0)
    end

    @streams = @streams.paginate(page: params[:page])

    #if a stock gets viewed, update the stocks table so that the stock gets real time stock data.
    if (@stock.viewed == false)
      days = 6
      ScraperPublic.google_intraday(@stock.ticker_symbol, days)
      @stock.update(viewed:true)
    end



 		#creates prediction variable to be used to set up the prediction creation form (see app/views/shared folder)
  	@prediction = @current_user.predictions.build(stock_id: @stock.id)	

  	#If active prediction exists, show active prediction
  	if @prediction.active_prediction_exists?
  		@prediction = Prediction.find_by(user_id: @current_user.id, stock_id: @stock.id, active: true)
  	end

    #Determines relationship between current user and target user
    @target = @stock

  	@comment_stream_inputs = "Stock:#{@stock.id}"
  	@prediction_stream_inputs = "Stock:#{@stock.id}"

    @prediction_end_input_page = "stockspage" #for the prediction details box, set the input page for the prediction cancel button.

    
    @graph_buttons = ["1d", "5d", "1m", "3m", "6m", "1yr", "5yr"]
    #used by the view to generate the html buttons

    gon.ticker_symbol = @stock.ticker_symbol

    respond_to do |format|
      format.html
      format.json {
        settings = {ticker_symbol: @stock.ticker_symbol, current_user: current_user}
        graph = Graph.new(settings)
        render json: {
          :my_prediction => graph.my_prediction,
          :predictions => graph.predictions,
          :daily_prices => graph.daily_prices,
          :daily_forward_prices => graph.daily_forward_prices,
          :intraday_prices => graph.intraday_prices,
          :intraday_forward_prices => graph.intraday_forward_prices
        }
      }
    end

	end
end
