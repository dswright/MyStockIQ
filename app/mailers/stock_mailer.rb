class StockMailer < ActionMailer::Base
	default from: "sender@example.com"
	def new_stocks(stock_array)
		@stock_array = stock_array
		mail(to: "dylansamuelwright@gmail.com", subject: "New Stocks Added")
	end

	def stocks_failed()
		mail(to: "dylansamuelwright@gmail.com", subject: "Stock Names Scraper Failed")
	end

end
