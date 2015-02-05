class PredictionendsController < ApplicationController

  def create
    prediction = Prediction.find_by(id: params[:id])

    response_msgs = []

    prediction_already_ended = false
    if Predictionend.where(prediction_id:prediction.id).exists?
      prediction_already_ended = true
      response_msgs << "prediction has already been cancelled."
    end

    unless prediction_already_ended
      children = Stream.where(target_type: 'Prediction', target_id: prediction.id)
      

      prediction_ended = false
      if prediction.start_time < Time.zone.now || children.exists?
        prediction_ended = true

        prediction.active = false
        prediction.save

        predictionend = prediction.predictionends.build()
        predictionend.actual_end_time = Time.zone.now.utc_time_int.closest_start_time
        predictionend.actual_end_price = prediction.stock.daily_stock_price
        predictionend.end_price_verified = false
        predictionend.popularity_score = 0


        predictionend.save


        @prediction = current_user.predictions.build(stock_id: predictionend.prediction.stock.id) 

        #build a custom stream string for cancellations, which always have the same stream items.
        stream_string = "Prediction:#{prediction.id},Stock:#{prediction.stock.id}"

        #build stream items for cancellation.
        stream_params_process(stream_string).each do |stream|
          predictionend.streams.build(stream).save
        end
        stream = Stream.where(streamable_type: 'Predictionend', streamable_id: predictionend.id).first
        @stream_hash_array = Stream.stream_maker([stream], 0) #gets inserted to top of stream with ajax.

        response_msgs << "prediction ended."
      else
        @prediction_css_id = "Prediction_#{params[:id]}"
        @prediction_stream_inputs = "Stock:#{prediction.stock.id}"
        response_msgs << "prediction removed."
        @prediction = current_user.predictions.build(stock_id: prediction.stock.id) #this is built to produce the form again.
        
        prediction.destroy
      end
    end
    @response = response_maker(response_msgs)

    respond_to do |f|
      f.js {
        if prediction_already_ended
          'shared/_error_messages.js.erb'
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
