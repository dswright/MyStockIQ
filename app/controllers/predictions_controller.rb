class PredictionsController < ApplicationController

	require 'customdate'
	require 'popularity'
  require 'graph'
	

  def hover
    prediction = Prediction.find(params[:id])

    respond_to do |f|
      f.html { 
        render :partial => 'hover', :locals => { :prediction => prediction } #this is working...
      }
    end

  end

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		stock = Stock.find(prediction_params[:stock_id])

		#Create the prediction settings.
		prediction_start_time = Time.zone.now.utc_time_int.closest_start_time
		prediction_end_time = (Time.zone.now.utc_time_int + 
													(params[:days].to_i * 24* 3600) + 
													(params[:hours].to_i * 3600) + 
													(params[:minutes].to_i * 60)).closest_start_time
		
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
			response_msgs << "Your prediction starts and ends at the same time. Please increase your prediction end time."
			invalid_start = true
		end

		unless invalid_start
      @prediction_end_input_page = "stockspage" #set this variable for the cancel button form on the stockspage.
			@prediction.save
			@streams.each {|stream| stream.save}
			stream = Stream.where(streamable_type: 'Prediction', streamable_id: @prediction.id).first
			@stream_hashes = Stream.stream_maker([stream], 0) #gets inserted to top of stream with ajax.
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

	def show

	@prediction = Prediction.find_by(id:params[:id])
	@stock = @prediction.stock

		@current_user = current_user

    #if the prediction is active, run updates on the prediction so that its data is most up to date
    if @prediction.active_prediction_exists?
      @prediction.exceeds_end_price #if the stock price exceeds the prediction price, move date and set to active:false, create prediction end and stream items.
      @prediction.exceeds_end_time #if the current time exceeds the prediction end time, set active:false, create prediction ends, and stream items.
      @prediction.update_score #run an update of the current score.
    end
		#Stock's posts, comments, and predictions to be shown in the view
		streams = Stream.where(target_type: "Prediction", target_id: @prediction.id).limit(15)

    gon.ticker_symbol = @stock.ticker_symbol

    #unless streams == nil
    #  streams.each {|stream| stream.streamable.update_popularity_score}
    #end


    #this line makes sorts the stream by popularity score.
    #streams = streams.sort_by {|stream| stream.streamable.popularity_score}
    #streams = sort_by_popularity(streams)
    streams = streams.reverse

    unless streams == nil
      @stream_hash_array = Stream.stream_maker(streams, 0)
    end


  	@comment_stream_inputs = "Prediction:#{@prediction.id}"

    @prediction_end_input_page = "predictiondetails"
    
    @graph_buttons = ["1d", "5d", "1m", "3m", "6m", "1yr", "5yr"]
    #used by the view to generate the html buttons

    gon.ticker_symbol = @stock.ticker_symbol
    gon.prediction_id = @prediction.id

    respond_to do |format|
      format.html
      format.json {
        settings = {prediction:@prediction, ticker_symbol:@prediction.stock.ticker_symbol}
        graph = Graph.new(settings) #send in the owner of the prediction as the user... still not sure if that is correct.
        #remember these are the ruby functions... that generate the json api.
        render json: {
          :daily_prices => graph.daily_prices,
          :prediction => graph.prediction, #the specific prediction to be displayed on the graph.
          :predictionend => graph.predictionend,
          :intraday_prices => graph.intraday_prices
        }
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
