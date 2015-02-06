class PredictionendMailer < ActionMailer::Base
	default from: "Stockhero"
	def predictioncomplete(predictionend)
    @predictionend = predictionend
		mail(
			from: "Prediction@Stockhero.com",
			to: predictionend.prediction.user.email, 
			subject: "#{predictionend.prediction.stock.ticker_symbol} Prediction Complete!"
			)
	end
end
