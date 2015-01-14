class PredictionsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#sets up a hash of prediction parameters to build prediction object. 'prediction_params' method is defined below.
		prediction = prediction_params


		@prediction = @user.predictions.build(prediction)
		@prediction.days_remaining = to_days((@prediction.end_date - Time.now)).round

		@streams = []
		#Determines target type and id for Streams Model insert
		unless params[:stream_array].empty?
			stream_input_array = params[:stream_array].split(",")
			stream_input_array.each do |stream_item|
				#Must add validation of these parameters against existing stock/user ids to prevent hacking.
				stream_elements = stream_item.split(":")
				stream_input = {target_type: stream_elements[0], target_id: stream_elements[1]}
				@streams << @prediction.streams.build(stream_input)
			end
		end

		unless @prediction.invalid? or active_prediction_exists?(@prediction)
			@prediction.save
			@streams.each {|stream| stream.save}

			flash[:success] = "Prediction Created!"

			#Redirects back to previous page. If previous redirect is not specified, login_path is used.
			redirect_to request.referrer || login_path
		else

			render '/stocks/show/'
			#render stock_or_user_page(stream)
		end

	end

	def update

		predictions = Prediction.where(active: 1)

		predictions.each do |prediction|
			update_prediction(prediction)
		end

	end

	def destroy

		#Set prediction active = 0 and redirect back to previous page
		prediction = Prediction.find_by(id: params[:id])
		prediction.active = 0
		prediction.save
    	flash[:success] = "Prediction canceled!"
    	redirect_to request.referrer || login_path
	end

	private

	#def comment_params
	def prediction_params
			#Obtains parameters from 'prediction form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
			params.require(:prediction).permit(:prediction_price, :end_date, :prediction_comment, :score, :active, :start_price, :landing_page, :stock_id)
	end
end
