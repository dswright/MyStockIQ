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

	def update_score(prediction)
		stock = Stock.find_by(id: prediction.streams.stock_id)
		prediction_price = interpolate( start_price, start_price)
		actual_price = stock.daily_stock_price
	end

	def interpolate(x0, y0, x1, y1, x2)
        y2 = 0
        y2 = y0 + ((y1-y0)*(x2-x0)/(x1-x0))
    end

end
