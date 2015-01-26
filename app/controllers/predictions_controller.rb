class PredictionsController < ApplicationController

	respond_to :html, :js

	require 'customdate'

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#Create the prediction settings.
		prediction_start_time = Time.zone.now.utc_time_int.closest_start_time
		prediction_end_time = (Time.zone.now.utc_time_int + 
													(params[:days].to_i * 24* 3600) + 
													(params[:hours].to_i * 3600) + 
													(params[:minutes].to_i * 60)).closest_end_time
		prediction = {prediction_end_time: prediction_end_time, score: 0, active: true, start_price_verified:false, 
									end_price_verified:false, start_time: prediction_start_time }
		#merge the prediction settings with the params from the prediction form.
		prediction.merge(prediction_params)
		@prediction = @user.predictions.build(prediction)
		@prediction.start_price = @prediction.stock.daily_stock_price


		#Create the stream inserts for the prediction.
		@streams = []
		stream_params_array = stream_params_process(params[:stream_string])
		stream_params_array.each do |stream_item|
			@streams << @prediction.streams.build(stream_item)
		end

		#Create the proper response to the prediciton input.
		@response_msg = []

		if @prediction.invalid?
			@response_msg << "Prediction invalid. Please refresh page and try again."
		end

		if @prediction.active_prediction_exists?
			@response_msg << "You already have an active prediction on #{stock.ticker_symbol}"
		end

		if prediction.prediction_end_time <= prediction.prediction_start_time
			@response_msg << "Today's market is currently closed. Please end your prediction when the market is open."
		end

		unless @prediction.invalid? or @prediction.active_prediction_exists? or prediction.prediction_end_time <= prediction.prediction_start_time
			@prediction.save
			@streams.each {|stream| stream.save}
			@response_msg + ["Prediction input!", "start price: #{prediction.start_price}", "start time: #{prediction.start_time}", 
				"end time: #{prediction.end time}", "end price: #{prediction.end_price}", "start price will be updated at the start time."]
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
		prediction.actual_end_time = Time.zone.now.closest_end_time
		prediction.save

		@resonse_box = "prediction is cancelled.. send this to ajax response."

    redirect_to request.referrer || login_path
		
		#need to put the ajax response here..
		#need to put that response box on the page...

	end

	private

	#def comment_params
	def prediction_params
		#Obtains parameters from 'prediction form' in app/views/shared.
		#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
		params.require(:prediction).permit(:prediction_end_price, :prediction_comment, :score, :active, :start_price, :stock_id)
	end
end
