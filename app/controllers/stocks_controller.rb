class StocksController < ApplicationController

	#function to pull the whole stock file and then update all records
	def create

		#Retrive the stock array to use in the view.
		#The fetch stocks function also pulls all the stocks from a csv file updates database with any new records 
		#found in the csv file.
		#to be run daily to get new stocks.
		@stock_array = Stock.fetch_new_stocks
		StockMailer.new_stocks(@stock_array).deliver
	end
end
