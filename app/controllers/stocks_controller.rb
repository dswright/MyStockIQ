class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show

		@current_user = current_user
		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
		#Stock's posts, comments, and predictions to be shown in the view
		@streams = Stream.where(target_type: "stock", target_id: @stock.id)

		#creates comment variable to be used to set up the comment creation form (see app/views/shared folder)
    	@comment = Comment.new

   		#creates comment variable to be used to set up the prediction creation form (see app/views/shared folder)
    	@prediction = Prediction.new(score: 0, active: 1, start_price: @stock.daily_stock_price) 	

    	@comment_stream_inputs = "stock:#{@stock.id}"
    	@prediction_stream_inputs = "stock:#{@stock.id},user:2"

    	gon.ticker_symbol = params[:ticker_symbol]

    	gon.price_array = Stock.get_historical_prices(params[:ticker_symbol])    

    	#this gets used by the view to generate the html buttons.

    	latest_utc_date = Stock.get_latest_date(gon.price_array)
    	@date_limits_array = Stock.create_x_date_limits(latest_utc_date)

	end

end
