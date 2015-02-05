class PredictionendWorker
  include Sidekiq::Worker
  require 'scraper'

  #for this prediction, scrape the google data, check to see if there is a valid minute in the array, reset the prediction prices
  #based on that valid minute stock price.
  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    predictionend = Predictionend.find_by(prediction_id: prediction.id)
    minute_array = ScraperPublic.google_minute(prediction.stock.ticker_symbol)
    times_ahead = minute_array.select {|minute| minute["date"] >= predictionend.actual_end_time}
    unless times_ahead.empty? 
      min_minute = times_ahead.min_by {|item| item["date"]}
      predictionend.update(actual_end_time:min_minute["date"], actual_end_price:min_minute["close_price"].round(2), end_price_verified:true)
      prediction.final_update_score
      #send email here when prediction update is done.         
    end
  end
end