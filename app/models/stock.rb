class Stock < ActiveRecord::Base
	require 'csv'
	require 'open-uri'

	validates :stock, 				presence: true,
                    				format: { with: /\A([a-zA-Z0-9 _\'\"().&\/,-]+)\z/ },
														uniqueness: {case_sensitive: false}

	validates	:ticker_symbol, presence: true,
														uniqueness: {case_sensitive: false}


	#this function is not perfectly tested. It could break without test failure.
	def Stock.fetch_new_stocks
		url = "http://finviz.com/export.ashx?v=111&&o=ticker"
		Stock.delete_all
		stock_array = []
		open(url) do |f|
			f.each_line do |line|
				CSV.parse(line) do |row|
					#unless the stock is already in the database.
					unless Stock.find_by ticker_symbol: row[1]
						unless row[1] == "CRESY" || row[1] == "HYHG"
							#use the new_stock method to create the new stock row out of each csv file row.
							stock_array << Stock.new_stock(row)
						end
					end
				end
			end
		end
		return stock_array
	end

	def Stock.new_stock(row)
		stock_hash = { 
			stock: row[2],
			exchange: nil,
			active: true,
			ticker_symbol: row[1],
			date: nil,
			daily_percent_change: nil,
			daily_volume: row[10],
			price_to_earnings: row[7],
			ytd_percent_change: nil,
			daily_stock_price: nil,
			stock_industry: row[4],
			stock_sector: row[3]
		}

		#if the new stock data is valid, make the new_stock row a new Stock model object to save to the db.
		if new_stock = Stock.new(stock_hash)
			#save to the stocks table.
			new_stock.save
			return stock_hash
		else
			return stock_hash = {failed: true}
		end

		#return the stockhash for creation of the stock_array.
		return stock_hash
	end
end
