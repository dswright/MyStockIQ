class PredictionsController < ApplicationController

	require 'customdate'
	require 'popularity'
  require 'graph'
	

  def hover_daily
    prediction = Prediction.find(params[:id])

    respond_to do |f|
      f.html {
        render :partial => 'predictions/hover_daily.js.erb', :locals => { :prediction => prediction } #this is working...
        #render :partial => 'shared/graph/daily_prediction', :locals => { :prediction => prediction_data } #this is working...
      }
    end
  end
  

  def hover_intraday
    prediction = Prediction.find(params[:id])

    respond_to do |f|
      f.html {
        render :partial => 'predictions/hover_intraday.js.erb', :locals => {:prediction => prediction } #this is working...
      }
    end
  end

  def details_hover_intraday
    params_break = params[:id].split("-")
    prediction = Prediction.find_by(id:params_break[0])
    prediction_custom = {}

    if (params_break[1] == "0")
      prediction_custom[:price] = prediction.start_price
      prediction_custom[:date] = prediction.start_time
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    elsif (params_break[1] == "1")
      prediction_custom[:price] = prediction.prediction_end_price
      prediction_custom[:date] = prediction.prediction_end_time
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    elsif (params_break[1] == "2")
      prediction_custom[:price] = prediction.predictionend.actual_end_time
      prediction_custom[:date] = prediction.predictionend.actual_end_price
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    end

    render :partial => 'predictions/details_hover_intraday.js.erb', :locals => {:prediction_custom => prediction_custom, :prediction => prediction}

  end

    def details_hover_daily
    params_break = params[:id].split("-")
    prediction = Prediction.find_by(id:params_break[0])
    prediction_custom = {}

    if (params_break[1] == "0")
      prediction_custom[:price] = prediction.start_price
      prediction_custom[:date] = prediction.start_time
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    elsif (params_break[1] == "1")
      prediction_custom[:price] = prediction.prediction_end_price
      prediction_custom[:date] = prediction.prediction_end_time
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    elsif (params_break[1] == "2")
      prediction_custom[:price] = prediction.predictionend.actual_end_time
      prediction_custom[:date] = prediction.predictionend.actual_end_price
      prediction_custom[:score] = prediction.score
      prediction_custom[:id] = prediction.id
    end

    render :partial => 'predictions/details_hover_daily.js.erb', :locals => {:prediction_custom => prediction_custom, :prediction => prediction}

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
									start_time: prediction_start_time}

		#merge the prediction settings with the params from the prediction form.
		prediction.merge!(prediction_params)
		@prediction = @user.predictions.build(prediction)
		@prediction.start_price = stock.daily_stock_price

		@graph_time = prediction_end_time.utc_time_int.graph_time_int


		#Create the proper response to the prediciton input.
		response_msgs = []

		invalid_start = false
		if @prediction.invalid?
			@prediction.errors.full_messages.each do |message|
        response_msgs << message
      end
      response_msgs << "invalid prediction"
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
      
      #Create the stream inserts for the prediction.
      @streams = []
      stream_params_array = stream_params_process(params[:stream_string])
      stream_params_array.each do |stream_item|
        @prediction.streams.create(stream_item)
      end

      @prediction.build_popularity(score:0).save #build the popularity score item for predictions
			@streams = [Stream.where(streamable_type: 'Prediction', streamable_id: @prediction.id).first]
			response_msgs << "Prediction input!"
		end

		@response = response_maker(response_msgs)

		respond_to do |f|
      f.js { 
        if invalid_start
         render 'shared/_error_messages.js.erb'
        else 
          render "predictions/create.js.erb"
        end 
      }
    end
	end

	def show
  return if user_logged_in? #redirects the user to the login page if they are not logged in.

	@prediction = Prediction.find_by(id:params[:id])
	@stock = @prediction.stock

		@current_user = current_user

    #if the prediction is active, run updates on the prediction so that its data is most up to date
    if @prediction.active_prediction_exists?
      @prediction.exceeds_end_price #if the stock price exceeds the prediction price, move date and set to active:false, create prediction end and stream items.
      @prediction.exceeds_end_time #if the current time exceeds the prediction end time, set active:false, create prediction ends, and stream items.
      @prediction.update_score #run an update of the current score.
    end
		#replies_update. These need to be changed to replies.
    #stream removed until replies are updated.
		@streams = Stream.where(targetable_type: "Prediction", targetable_id: @prediction.id).limit(15)

    gon.ticker_symbol = @stock.ticker_symbol

    #unless streams == nil
    #  streams.each {|stream| stream.streamable.update_popularity_score}
    #end

    #this line makes sorts the stream by popularity score.
    #streams = streams.sort_by {|stream| stream.streamable.popularity_score}
    #streams = sort_by_popularity(streams)
    #@streams = @streams.reverse
    
    @streams = @streams.paginate(page: params[:page], per_page: 10)

  	@comment_stream_inputs = "Prediction:#{@prediction.id}"

    @prediction_end_input_page = "predictiondetails"
    
    @graph_buttons = ["1D", "5D", "1M", "3M", "6M", "1Yr", "5Yr"]
    #used by the view to generate the html buttons

    gon.ticker_symbol = @stock.ticker_symbol
    gon.prediction_id = @prediction.id

    respond_to do |format|
      format.html
      format.json {
        settings = {prediction:@prediction, ticker_symbol:@prediction.stock.ticker_symbol, start_point:"predictiondetails"}
        graph = Graph.new(settings) #send in the owner of the prediction as the user... still not sure if that is correct.
        #remember these are the ruby functions... that generate the json api.
        render json: {
          :daily_prices => graph.daily_prices,
          :prediction => graph.prediction, #the specific prediction to be displayed on the graph.
          :predictionend => graph.predictionend,
          :intraday_prices => graph.intraday_prices,          
          :daily_price_ids => graph.daily_price_ids,
          :intraday_price_ids => graph.intraday_price_ids,
          :prediction_details_id => graph.prediction_details_id
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
