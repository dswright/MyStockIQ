class StockMailer < ActionMailer::Base
	default from: "sender@example.com"
	def new_stocks(stock_array)
		@stock_array = stock_array
		mail(to: "dylansamuelwright@gmail.com", subject: "#{stock_array.count} New Stocks Added")
	end
end
