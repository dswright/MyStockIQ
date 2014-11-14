class Stock < ActiveRecord::Base
	require 'csv'
	require 'open-uri'
	require 'uri'
	require 'json'

	validates :stock, 				presence: true,
														uniqueness: {case_sensitive: false}

	validates	:ticker_symbol, presence: true,
														uniqueness: {case_sensitive: false}


	#this function is not perfectly tested. It could break without test failure.
	def Stock.fetch_new_stocks
		stock_array = []
		x = 29
		x.times do |i|
			puts "page #{i}"
			if datastring = Stock.get_quandl_data(i, 0)
				dataset = JSON.parse(datastring)
				dataset["docs"].each do |row|
					stock_array << Stock.new_stock(row)
				end
			end
		end
		return stock_array
	end

	def Stock.get_quandl_data(i, count)
		url = "http://www.quandl.com/api/v2/datasets.json?source_code=EOD&per_page=300&page=#{i}&auth_token=sVaP2d6ACjxmP-jM_6V-"
		
		if datastring = open(url).read
			return datastring
		else
			count = count + 1
			if count >= 10
				StockMailer.stocks_failed.deliver
				return false
			end
			Stock.get_quandl_data(i, count)
		end
	end


	def Stock.new_stock(row)
		code = row["code"]
		realname = row["name"].gsub(/ \(#{code}\) Stock Prices, Dividends and Splits/,"")

		stock_hash = { 
			stock: realname,
			exchange: nil,
			active: true,
			ticker_symbol: code,
			date: nil,
			daily_percent_change: nil,
			daily_volume: nil,
			price_to_earnings: nil,
			ytd_percent_change: nil,
			daily_stock_price: nil,
			stock_industry: nil,
			stock_sector: nil
		}

		#if the new stock data is valid, make the new_stock row a new Stock model object to save to the db.
		new_stock = Stock.new(stock_hash)
			#save to the stocks table.
		if new_stock.save
			stock_hash[:failed] = false
			return stock_hash
		else
			stock_hash[:failed] = true
			return stock_hash
		end
	end
end
