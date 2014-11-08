require 'rake'

task :fetch_new_stocks => :environment do
	stock_array = Stock.fetch_new_stocks
	#stock_array.each do |stock|
	#	puts "#{stock[:ticker_symbol]} - #{stock[:stock]}"
	#end
	StockMailer.new_stocks(stock_array).deliver
end

task :greet do
	puts "greets boring"
end
