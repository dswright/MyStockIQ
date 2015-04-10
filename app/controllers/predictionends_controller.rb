class PredictionendsController < ApplicationController

  def create
    
    #the predcitions controller is passed the prediction id to start.

    #make it impossible for another user to cancel another user's prediction. Confirm that the prediction belongs to
    #the user cancelling it.

    response_msgs = []

    prediction_gone = false
    if Prediction.where(id:params[:prediction_id]).exists? #check to see if the prediction exists, based on its id. 
      prediction = Prediction.find_by(id: params[:prediction_id]) #if the prediction exists, find it.
      if Predictionend.where(prediction_id:prediction.id).exists? #if the predictionend exists, then the prediction is already ended.
        prediction_gone = true
        response_msgs << "prediction has already been ended."
      end
    else #if the prediction does not exist, then the prediction has already been cancelled.
      prediction_gone = true
      response_msgs << "prediction has already been canceled"
    end

    unless prediction_gone #unless the prediction is already cancelled or ended, do all of this.
      #replies_update. Needs to be changed to replies when replies are available.
      children = Stream.where(targetable_type: 'Prediction', targetable_id: prediction.id) #check to see if there are children already.
      prediction_ended = false
      @prediction = current_user.predictions.build(stock_id: prediction.stock.id) #this is built to produce the form again after the prediction is cancelled/ended.
      @prediction_stream_inputs = "Stock:#{prediction.stock.id}"

      if prediction.start_time < Time.zone.now || children.exists? #if children exist or the prediction started, end the prediction.
        prediction_ended = true

        prediction.active = false
        prediction.save #update the prediction to inactive.

        predictionend = prediction.build_predictionend() #build a prediction end.
        predictionend.actual_end_time = Time.zone.now.utc_time_int.closest_start_time
        predictionend.actual_end_price = prediction.stock.daily_stock_price
        predictionend.comment = params[:comment]
        predictionend.end_price_verified = false
        predictionend.save #save the prediction end.

        predictionend.build_popularity(score:0).save #build the popularity score item for predictions
        @predictionend = predictionend
        tags = predictionend.add_tags(prediction.stock.ticker_symbol) #Add tickersymbol ('$') and username ('@') tags to predictionend content

        @graph_time = @predictionend.actual_end_time.utc_time_int.graph_time_int

 
        #target the current user and the stock with stream items.
        predictionend.streams.create!(targetable_type:"Stock", targetable_id:prediction.stock.id)
        predictionend.streams.create!(targetable_type:"User", targetable_id:current_user.id)
        #Build additional stream items for comment targeting other stocks or users
        tags.each {|tag| predictionend.streams.create(targetable_id: tag.id, targetable_type: tag.class.name)}

        #build stream item to insert to the top of the stream.
        @streams = [Stream.where(streamable_type: 'Predictionend', streamable_id: @predictionend.id).first]
        
        response_msgs << "prediction ended."
      else #if there are no children, and the prediction has not started, cancel the prediction.
        @prediction_css_id = "Prediction_#{params[:prediction_id]}" #this is used to eliminate the stream item from the page when cancelled.
        @prediction_stream_inputs = "Stock:#{prediction.stock.id},User:#{current_user.id}" #this is used to define the target stream items for the new prediction input form.
        response_msgs << "prediction removed."
        prediction.destroy
      end
    end

    @response = response_maker(response_msgs)
    respond_to do |f|
      f.js {
        if params[:input_page] == "stockspage"
          if prediction_gone
            render 'shared/_error_messages.js.erb'
          else
            if prediction_ended
              render "stockpage_ended.js.erb"
            else
              render "stockpage_removed.js.erb" 
            end
          end
        end
        if params[:input_page] == "predictiondetails"
          if prediction_gone
            render 'shared/_error_messages.js.erb' #this one is easy and can stay the same.
          else
            if prediction_ended
              render "predictiondetails_ended.js.erb" #this will have to be fancy. Alot of shit will need to change on the page with this one.
            else
              render js: "window.location.pathname='/stocks/#{@prediction.stock.ticker_symbol}/'" #redirect to the stockpage after cancellation on the details page.
            end
          end
        end
      }
    end
  end
end
