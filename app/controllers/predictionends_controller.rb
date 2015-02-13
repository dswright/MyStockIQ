class PredictionendsController < ApplicationController

  def create
    
    #the predcitions controller is passed the prediction id to start.

    #make it impossible for another user to cancel another user's prediction. Confirm that the prediction belongs to
    #the user cancelling it.

    response_msgs = []

    prediction_gone = false
    if Prediction.where(id:params[:id]).exists? #check to see if the prediction exists, based on its id. 
      prediction = Prediction.find_by(id: params[:id]) #if the prediction exists, find it.
      if Predictionend.where(prediction_id:prediction.id).exists? #if the predictionend exists, then the prediction is already ended.
        prediction_gone = true
        response_msgs << "prediction has already been ended."
      end
    else #if the prediction does not exist, then the prediction has already been cancelled.
      prediction_gone = true
      response_msgs << "prediction has already been canceled"
    end

    unless prediction_gone #unless the prediction is already cancelled or ended, do all of this.
      children = Stream.where(target_type: 'Prediction', target_id: prediction.id) #check to see if there are children already.
      prediction_ended = false
      if prediction.start_time < Time.zone.now || children.exists? #if children exist or the prediction started, end the prediction.
        prediction_ended = true

        prediction.active = false
        prediction.save #update the prediction to inactive.

        predictionend = prediction.build_predictionend() #build a prediction end.
        predictionend.actual_end_time = Time.zone.now.utc_time_int.closest_start_time
        predictionend.actual_end_price = prediction.stock.daily_stock_price
        predictionend.end_price_verified = false
        predictionend.popularity_score = 0
        predictionend.save #save the prediction end.

        #build a custom stream string for cancellations, which always have the same stream items.

        #target the current user and 
        predictionend.streams.build(target_type:"Stock", target_id:prediction.stock.id).save
        predictionend.streams.build(target_type:"User", target_id:current_user.id).save

        #build stream item to insert to the top of the stream.
        stream = Stream.where(streamable_type:"Predictionend", streamable_id:predictionend.id)
        @stream_hash_array = Stream.stream_maker([stream], 0) #gets inserted to top of stream with ajax.

        response_msgs << "prediction ended."
      else #if there are no children, and the prediction has not started, cancel the prediction.
        @prediction_css_id = "Prediction_#{params[:id]}" #this is used to eliminate the stream item from the page when cancelled.
        @prediction_stream_inputs = "Stock:#{prediction.stock.id},User:#{current_user.id}" #this is used to define the target stream items for the new prediction input form.
        response_msgs << "prediction removed."
        @prediction = current_user.predictions.build(stock_id: prediction.stock.id) #this is built to produce the form again.
        
        prediction.destroy
      end
    end

    @response = response_maker(response_msgs)

    respond_to do |f|
      f.js {
        if prediction_gone
          render 'shared/_error_messages.js.erb'
        else
          if prediction_ended
            render "ended.js.erb"
          else
            render "removed.js.erb" 
          end
        end
      }
    end
  end
end
