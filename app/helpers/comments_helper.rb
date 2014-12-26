module CommentsHelper
	def stock_or_user_page(stream)
		if stream.target_type = "stock"
			stock = Stock.find_by(id: stream.target_id)
			"/stocks/#{stock.ticker_symbol}/"
		else
			login_path
		end
	end

	def stock_or_user_view(stream)
		if stream.ticker_symbol = "stock"
			"/stocks/show"
		else
			"/users/show/"
		end
	end
	
end

