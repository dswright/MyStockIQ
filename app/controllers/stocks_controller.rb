class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
	end

end
