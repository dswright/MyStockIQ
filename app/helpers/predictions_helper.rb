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


	def same_sign?(num1, num2)
		if num1 >= 0 && num2 >= 0
			return true
		elsif num1 < 0 && num2 < 0
			return true
		else
			return false
		end
	end


  	def number_of_predictions(object)
  		Prediction.where(target_id: object.id).count
  	end

	#Converts seconds to days
	def to_days(seconds)
		days = seconds/(60*60*24)
	end

	def interpolate(x0, y0, x1, y1, x2)
        y2 = 0
        y2 = y0 + ((y1-y0)*(x2-x0)/(x1-x0))
    end

end
