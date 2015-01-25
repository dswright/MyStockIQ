class PredictionsController < ApplicationController
	require 'customdate'

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#sets up a hash of prediction parameters to build prediction object. 'prediction_params' method is defined below.
		prediction = prediction_params

		prediction_end_time = Time.zone.now.utc_time_int + (params[:days].to_i * 24* 3600)  + (params[:hours].to_i * 3600) + (params[:minutes].to_i * 60)

		#now test if this is a valid time, if not, move it forward.
		#return closest valid time function
		@prediction = @user.predictions.build(prediction)

		@prediction.score = 0
		@prediction.active = true
		@prediction.start_price_verified = false
		@prediction.end_price_verified = false

		@prediction.prediction_end_time = prediction_end_time.closest_end_time
		@prediction.actual_end_time = nil
		@prediction.actual_end_price = nil

		@prediction.start_time = Time.zone.now.utc_time_int.closest_start_time

		if @prediction.start_time > @prediction.prediction_end_time
			@error_msg = "invalid prediction. Please start and end the prediction during market hours."
			#make this a condition of saving the prediction.
		end

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

		unless @prediction.invalid? or @prediction.active_prediction_exists?
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
		prediction.active = false
		prediction.actual_end_time = CustomDate.closest_end_time(Time.zone.now)
		prediction.save

    flash[:success] = "Prediction canceled!"
    redirect_to request.referrer || login_path
	end

	private

	#def comment_params
	def prediction_params
		#Obtains parameters from 'prediction form' in app/views/shared.
		#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
		params.require(:prediction).permit(:prediction_end_price, :prediction_comment, :score, :active, :start_price, :stock_id)
	end
end
