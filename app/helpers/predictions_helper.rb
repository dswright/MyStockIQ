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

	def calculate_score(prediction_percentage, actual_percentage)
		#IF PREDICTION IS CORRECT: 
		if same_sign?(prediction_percentage, actual_percentage)

			#points are awarded
			if prediction_percentage.abs <= actual_percentage.abs
				score = prediction_percentage.abs.round(2)
			else 
				score = (actual_percentage.abs - (prediction_percentage.abs - actual_percentage.abs)).round(2)
				score = 0 if score < 0
			end

		#IF PREDICTION IS INCORRECT:
		else
			#No points are awarded
			score = 0
		end
	end

	def update_prediction(prediction)
		#Check the amount of time remaining on the prediction
		prediction.days_remaining = prediction.end_date - Time.now
		prediction.days_remaining = 0 if prediction.days_remaining < 0	

		#Set prediction to be inactive if there is no time remaining
		if prediction.days_remaining = 0
			prediction.active = 0
		end

		#Finds stock associated with prediction
		stock = Stock.find_by(id: prediction.stock_id)

		#Calculates today's projected prediction price
		todays_prediction = interpolate( prediction.created_at, prediction.start_price, prediction.end_date, prediction.prediction_price, Time.now )
		
		#Actual stock price for comparison
		todays_price = stock.daily_stock_price

		#Calculates percentchange of prediction/start price and actual price/start price
		prediction_percentage = percent_change(todays_prediction, prediction.start_price)
		actual_percentage = percent_change(todays_price, prediction.start_price)

		#Update prediction score
		prediction.score = calculate_score(prediction_percentage, actual_percentage)

		prediction.save
	end

	def active_prediction_exists?(prediction)

	 	#Find current user prediction related to that stock
	 	other_predictions = Prediction.where(active: 1, user_id: prediction.user_id, stock_id: prediction.stock_id)

    	if other_predictions == nil
      		false
    	else 
      		true 
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
