module StocksHelper

	def current_stock
		@stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])
	end
	
	def stock_page(model)
		"/stocks/#{model.ticker_symbol}"
	end
end
