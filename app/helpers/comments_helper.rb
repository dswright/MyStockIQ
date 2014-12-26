module CommentsHelper
	def stock_or_user_page(target_string)
		stream_input_array = target_string.split(",")
		first_item = stream_input_array[0].split(":")
		if first_item[0] == "user"
			"/users/#{first_item[1]}"
		elsif first_item[0] == "stock"
			"stocks/#{first_item[1]}"
		else
			login_path
		end
	end

	def stock_or_user_view(target_string)
		stream_input_array = target_string.split(",")
		first_item = stream_input_array[0].split(":")
		if first_item[0] == "user"
			"/users/show/"
		elsif first_item[0] == "stock"
			"/stocks/show"
		end
	end
end

