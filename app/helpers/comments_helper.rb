module CommentsHelper

	def stock_or_user_page(stream_item_one)
		if stream_item_one[:target_type] == "stock"
			"/stocks/#{stream_item_one[:target_id]}/"

		elsif stream_item_one[:target_type] == "user"
			"/users/#{stream_item_one[:target_id]}/"
		end
	end
end

