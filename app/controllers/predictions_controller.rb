class PredictionsController < ApplicationController

	require 'customdate'
	require 'popularity'
	
	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		stock = Stock.find(prediction_params[:stock_id])

		#Create the prediction settings.
		prediction_start_time = Time.zone.now.utc_time_int.closest_start_time
		prediction_end_time = (Time.zone.now.utc_time_int + 
													(params[:days].to_i * 24* 3600) + 
													(params[:hours].to_i * 3600) + 
													(params[:minutes].to_i * 60)).closest_end_time
		prediction = {stock_id: stock.id, prediction_end_time: prediction_end_time, score: 0, active: true, start_price_verified:false, 
									start_time: prediction_start_time, popularity_score:0 }

		#merge the prediction settings with the params from the prediction form.
		prediction.merge!(prediction_params)
		@prediction = @user.predictions.build(prediction)
		@prediction.start_price = stock.daily_stock_price

		@graph_time = prediction_end_time.utc_time_int.graph_time_int


		#Create the stream inserts for the prediction.
		@streams = []
		stream_params_array = stream_params_process(params[:stream_string])
		stream_params_array.each do |stream_item|
			@streams << @prediction.streams.build(stream_item)
		end

		#Create the proper response to the prediciton input.
		response_msgs = []

		invalid_start = false
		if @prediction.invalid?
			response_msgs << "Prediction invalid. Please refresh page and try again."
			invalid_start = true
		end

		if @prediction.active_prediction_exists?
			response_msgs << "You already have an active prediction on #{stock.ticker_symbol}"
			invalid_start = true
		end

		if @prediction.prediction_end_time <= @prediction.start_time
			response_msgs << "Today's market is currently closed. Please end your prediction when the market is open."
			invalid_start = true
		end

		unless invalid_start
			@prediction.save
			@streams.each {|stream| stream.save}
			stream = Stream.where(streamable_type: 'Prediction', streamable_id: @prediction.id).first
			@stream_hash_array = Stream.stream_maker([stream], 0) #gets inserted to top of stream with ajax.
			response_msgs << "Prediction input!"
		end

		@response = response_maker(response_msgs)

		respond_to do |f|
      f.js { 
        if invalid_start
         render 'shared/_error_messages.js.erb'
        else 
          render "create.js.erb"
        end 
      }
    end
	end

	private

	#def comment_params
	def prediction_params
		#Obtains parameters from 'prediction form' in app/views/shared.
		#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
		params.require(:prediction).permit(:prediction_end_price, :prediction_comment, :stock_id)
	end
end
