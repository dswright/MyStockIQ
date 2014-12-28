module PredictionsHelper

	def percent_change(prediction)
		((prediction.prediction_price - prediction.start_price)/prediction.start_price*100).round(1)
	end

	def increase_or_decrease?(prediction)
		if prediction.prediction_price - prediction.start_price >= 0
			"increase"
		else
			"decrease"
		end
	end

	def prediction_duration(prediction)
		#expressed in units of days
		days = (prediction.end_date - prediction.created_at)/(60*60*24)
		pluralize(days.ceil, "day")
	end

end
