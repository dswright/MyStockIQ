module CommentsHelper

	def stock_or_user_page(comment)
		if comment.ticker_symbol != nil
			"/stocks/#{comment.ticker_symbol}"
		else
			user_profile
		end
	end

	def stock_or_user_view(comment)
		if comment.ticker_symbol != nil
			'/stocks/show'
		else
			'/users/show'
		end
	end

end
