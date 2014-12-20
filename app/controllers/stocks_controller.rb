class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
    gon.ticker_symbol = params[:ticker_symbol]


    gon.price_array = Stock.get_historical_prices(params[:ticker_symbol])    

    #this gets used by the view to generate the html buttons.

    latest_utc_date = Stock.get_latest_date(gon.price_array)
    @date_limits_array = Stock.create_x_date_limits(latest_utc_date)

		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
	end

end
