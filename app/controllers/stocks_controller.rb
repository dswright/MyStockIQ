class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show

    ticker_symbol = params[:ticker_symbol]

		@current_user = current_user
		@stock = Stock.find_by(ticker_symbol: ticker_symbol)
		#Stock's posts, comments, and predictions to be shown in the view
		streams = Stream.where(target_type: "Stock", target_id: @stock.id)
    @stream_hash_array = Stream.stream_maker(streams, 0)

    #if a stock gets viewed, update the stocks table so that the stock gets real time stock data.
    if (@stock.viewed == false)
      stock_to_update.viewed = true
      stock_to_update.save
      IntradayWorker.perform_async(ticker_symbol, 5)
    end

		#creates comment variable to be used to set up the comment creation form (see app/views/shared folder)
  	@comment = Comment.new
    @like = Like.new

 		#creates comment variable to be used to set up the prediction creation form (see app/views/shared folder)
  	@prediction = Prediction.new(score: 0, active: 1, start_price: @stock.daily_stock_price) 	

  	@comment_stream_inputs = "Stock:#{@stock.id}"
  	@prediction_stream_inputs = "Stock:#{@stock.id}"

    @prediction_landing_page = "stocks:#{@stock.ticker_symbol}"
    @comment_landing_page = "stocks:#{@stock.ticker_symbol}"
    @stream_comment_landing_page = "stocks:#{@stock.ticker_symbol}"
  

  	gon.ticker_symbol = ticker_symbol
  	gon.price_array = Stock.get_historical_prices(ticker_symbol)    

  	#this gets used by the view to generate the html buttons.

  	latest_utc_date = Stock.get_latest_date(gon.price_array)
  	@date_limits_array = Stock.create_x_date_limits(latest_utc_date)

	end

end
