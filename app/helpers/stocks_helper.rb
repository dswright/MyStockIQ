module StocksHelper

	def self.current_stock(ticker_symbol)
		return Stock.find_by(ticker_symbol: ticker_symbol)
	end
	
	def self.stock_page(model)
		"/stocks/#{model.ticker_symbol}"
	end
end
