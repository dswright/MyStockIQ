class ExampleMailer < ActionMailer::Base
	default from: "sender@example.com"
	def new_stocks(stock_array)
		@stock_array = stock_array
		insertedcount = @stock_array[:inserted].count
		failedcount = @stock_array[:failed].count
		mail(
			from: "scraperalerts@stockhero.com",
			to: "dylansamuelwright@gmail.com", 
			subject: "#{insertedcount} New Stocks Added, #{failedcount} Stocks Failed to Insert"
			)
	end

	def stocks_failed()
		mail(to: "dylansamuelwright@gmail.com", subject: "Stock Names Scraper Failed")
	end

end
