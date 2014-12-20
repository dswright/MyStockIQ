class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	def create

		#Stock.fetch_new_stocks pulls the 28 pages of stock tickers from Quandl and checks for any new ticker symbols.
		#Saves new tickers to the db.
		#Returns list of inserted and failed inserts to the stock_array.
		@stock_array = Stock.fetch_new_stocks
		#Takes the array of inserted stock objects and updates them with the correct stock industry.
		#Returns list of updated stock objects to the stock_array.
		@stock_array[:inserted] = Stock.return_industry_array(@stock_array[:inserted])
		#additionally update the inserted values with the correct pe ratio.
		@stock_array[:inserted] = Stock.return_pe(@stock_array[:inserted])
		#Sends an email with the array of failed and inserted stocks.
		StockMailer.new_stocks(@stock_array).deliver_now
	end

	def show
		#'current_stock' is defined in Stock Helper functions
		@stock = current_stock

		@posts = Stream.where(stock_id: @stock.id)
		@comments = Comment.where(ticker_symbol: @stock.ticker_symbol)

		#creates post variable to be used to set up the post creation form (see app/views/shared folder)
    	#@post = current_user.streams.build() if logged_in?

    	@comment = Comment.new(ticker_symbol: @stock.ticker_symbol)
	end
end
 
