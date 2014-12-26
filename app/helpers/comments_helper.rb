module CommentsHelper
	def stock_or_user_page(stream)
		if stream.target_type = "stock"
			stock = Stock.find_by(id: stream.target_id)
			"/stocks/#{stock.ticker_symbol}/"
		elsif stream.target_type = "user"
			user = User.find_by(id: stream.target_id)
			"/stocks/#{user.username}"
		end
	end

	def stock_or_user_view(stream)
		if stream.target_type = "stock"
			"/stocks/show/"
		elsif stream.target_type = "user"
			"/users/show/"
		end
	end
	
end

