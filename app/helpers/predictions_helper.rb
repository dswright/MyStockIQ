module PredictionsHelper

	def prediction_percent(prediction)
		((prediction.prediction_price - prediction.start_price)/prediction.start_price*100).round(1)
	end

	def increase_or_decrease?(prediction)
		if prediction.prediction_price - prediction.start_price >= 0
			"increase"
		else
			"decrease"
		end
	end

	def percent_change(new_score, base_score)
		((new_score - base_score)/base_score*100)
	end


  	def number_of_predictions(object)
  		Prediction.where(target_id: object.id).count
  	end

	#Converts seconds to days
	def to_days(seconds)
		days = seconds/(60*60*24)
	end


end
