class PredictionsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#sets up a hash of prediction parameters to build prediction object. 'prediction_params' method is defined below.
		prediction = prediction_params

		@prediction = @user.predictions.build(prediction)

		#Determines target type and id for Streams Model insert
		unless params[:stream_array].empty?
			stream_input_array = params[:stream_array].split(",")
			stream_input_array.each do |stream_item|
				#Must add validation of these parameters against existing stock/user ids to prevent hacking.
				stream_elements = stream_item.split(":")
				stream_input = {target_type: stream_elements[0], target_id: stream_elements[1]}
				@stream = @prediction.streams.build(stream_input)
			end
		end

		if @prediction.valid?
			@prediction.save
			@stream.save
			flash[:success] = "Prediction Created!"
			redirect_to stock_or_user_page(@stream)

		else
			render '/stocks/show/'
			#render stock_or_user_page(stream)
		end

	end

	private

	#def comment_params
	def prediction_params
			#Obtains parameters from 'prediction form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
			params.require(:prediction).permit(:prediction_price, :end_date, :prediction_comment, :score)
	end
end
