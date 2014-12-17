class StocksController < ApplicationController

	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
	end

  def create
    x = 30
    1.upto(30) do |i|
      # set data_set_docs = to the "docs" array of objects from the quandl json file
      StocksWorker.perform_async(i)
    end
  end

  def pe_ratios
    stock_array = Stock.where(active:true)
    sliced = stock_array.each_slice(199).to_a
    sliced.each do |small_stock_array|
      small_array = []
      small_stock_array.each do |single_stock|
        small_array << {"ticker_symbol" => single_stock.ticker_symbol}
      end
      PEWorker.perform_async(small_array)
    end
  end

end
