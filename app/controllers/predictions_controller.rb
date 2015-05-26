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

    @messages = {}
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		stock = Stock.find(prediction_params[:stock_id])

		#Create the prediction settings.
		prediction_start_time = Time.zone.now.graph_time.closest_start_time # this returns a timestamp
		    
    prediction_end_str = (params[:end_day] + " " + params[:end_time])
    prediction_end_time = (DateTime.parse(prediction_end_str).utc.to_i*1000).closest_start_time #closest_start_time takes a graphtime and returns a timestamp date.

		prediction = {stock_id: stock.id, prediction_end_time: prediction_end_time, score: 0, active: true, start_price_verified:false, 
									start_time: prediction_start_time, graph_start_time: prediction_start_time.graph_time, graph_end_time: prediction_end_time.graph_time}

		#merge the prediction settings with the params from the prediction form.
		prediction.merge!(prediction_params)
		@prediction = @user.predictions.build(prediction)
		@prediction.start_price = stock.daily_stock_price
    @prediction.prediction_end_price = prediction_params[:prediction_end_price].to_i.round(2) #make sure the prediction end price is rounded to 2 places.

    tags = @prediction.add_tags(stock.ticker_symbol)
		@graph_time = @prediction.graph_end_time


		#Create the proper response to the prediciton input.
		response_msgs = []

		invalid_start = false
		if @prediction.invalid?
      #adds error message
      @prediction.invalid_start
			invalid_start = true
		end

		if @prediction.active_prediction_exists?
      #adds error message
      @prediction.already_exists
			invalid_start = true
		end

		if @prediction.prediction_end_time <= @prediction.start_time
      #adds error message
			@prediction.invalid_end_time
			invalid_start = true
		end

    if @prediction.valid?
  		unless invalid_start
        @prediction_end_input_page = "stockspage" #set this variable for the cancel button form on the stockspage.
  			@prediction.save
        
        @comment_stream_string = "Stock:#{@prediction.stock.id},User:#{@current_user.id}" #create stream string used by the new comment box.

        #Create the stream inserts for the prediction.
        @prediction.streams.create!(targetable_type: @user.class.name, targetable_id: @user.id)
        @prediction.streams.create!(targetable_type: stock.class.name, targetable_id: stock.id)
        #Build additional stream items for comment targeting other stocks or users
        tags.each {|tag| @prediction.streams.create(targetable_id: tag.id, targetable_type: tag.class.name)}

        @prediction.build_popularity(score:0).save #build the popularity score item for predictions
  			@streams = [Stream.where(streamable_type: 'Prediction', streamable_id: @prediction.id).first]
  			
        @messages[:success] = "Your prediction has been created!"
  		end
    end

		respond_to do |f|
      f.js { 

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

    @prediction_custom = {}
    @prediction_custom[:price] = @prediction.prediction_end_price
    @prediction_custom[:date] = @prediction.prediction_end_time
    @prediction_custom[:score] = @prediction.score
    @prediction_custom[:id] = @prediction.id

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
        graph = Graph.new(settings)
        #These functions generate the data for the json api.
        render json: {
          :daily_prices => graph.daily_prices,
          :intraday_prices => graph.intraday_prices,
          :prediction => graph.prediction, #the specific prediction to be displayed on the graph.
          :predictionend => graph.predictionend #the prediction end line, if it exists.
        }
      }
    end

	end


	private

	#def comment_params
	def prediction_params
		#Obtains parameters from 'prediction form' in app/views/shared.
		#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'predictions' model.
		params.require(:prediction).permit(:prediction_end_price, :content, :stock_id)
	end
end
