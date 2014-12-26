class PredictionsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		prediction = prediction_params

		prediction = @user.predictions.build(prediction)

		if prediction.valid?
			prediction.save
		end

	end

	private

	#def comment_params
	def prediction_params
			#Obtains parameters from 'prediction form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
			params.require(:predictions).permit(:prediction_price, :end_date, :prediction_comment, :score)
	end
end
