class StocksController < ApplicationController
require 'graph'
require 'scraper'
	
	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
    respond_to do |format|
      format.html {
        @stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])

    		@current_user = current_user

    		#Stock's posts, comments, and predictions to be shown in the view
        #will_paginate in view automatically generates params[:page]
    		@streams = Stream.where(target_type: "Stock", target_id: @stock.id).limit(20)
        @stream_hash_array = Stream.stream_maker(@streams, 0)

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


        @streams = @streams.paginate(page: params[:page], per_page: 10)

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
      }

      format.json {

        ticker_symbols = []
        stock_names = []
        Stock.where(active:true).where("UPPER(ticker_symbol) like UPPER(?)", "%#{params[:ticker_symbol]}%").limit(10).each do |stock|
          ticker_symbols << stock.ticker_symbol
        end

        render json: {
          :ticker_symbols => ticker_symbols       
        }
      }

    end

	end
end
