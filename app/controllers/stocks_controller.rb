class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
    gon.ticker_symbol = params[:ticker_symbol]



    stock_prices = Stockprice.where(ticker_symbol:params[:ticker_symbol])


    price_array = []
    stock_prices.each do |price|
      utc_time = Time.parse(price.date.to_s).getutc.to_time.to_i * 1000
      price_array << [utc_time, price.close_price]
    end
    price_array.sort_by! {|array| array[0]}

    gon.price_array = price_array




		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
	end

end
