

json.array! @streams do |stream|
		json.type stream.streamable_type
      json.content stream.streamable.content
      json.time_ago time_ago_in_words(stream.created_at)

      json.replies stream.streamable.replies do |reply|
        json.content reply.content
        json.time_ago time_ago_in_words(reply.created_at)
        json.user do
          json.username reply.user.username
          json.image image_path(reply.user.image.url)
        end
      end


      json.user do
        if stream.streamable_type == "Predictionend"
          json.username stream.streamable.prediction.user.username
          json.image stream.streamable.prediction.user.image.url
        else
          json.username stream.streamable.user.username
          json.image image_path(stream.streamable.user.image.url)
        end
      end
    if stream.streamable_type == "Prediction"
      json.ticker_symbol stream.streamable.stock.ticker_symbol
      json.prediction_end_price stream.streamable.prediction_end_price
      json.prediction_ending_in distance_of_time_in_words(stream.streamable.created_at, stream.streamable.prediction_end_time)
      json.score stream.streamable.score
    end

  #
	# json.targetable do
	# 	json.type stream.targetable_type
	# 	if stream.targetable_type == "User"
	# 		json.name stream.targetable.username
	# 	elsif stream.targetable_type == "Stock"
	# 		json.name stream.targetable.ticker_symbol
	# 	end
  #
	# end

end

