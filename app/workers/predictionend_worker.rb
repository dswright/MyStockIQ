class PredictionendWorker
  include Sidekiq::Worker
  require 'scraper'

  #for this prediction, scrape the google data, check to see if there is a valid minute in the array, reset the prediction prices
  #based on that valid minute stock price.
  def perform(predictionend_id)
    predictionend = Predictionend.find(predictionend_id)
    if (predictionend.actual_end_time + 1800 <= Time.zone.now) #checks to make sure that 30 minutes has passed before searching for the minute price. 
      minute_array = ScraperPublic.google_minute(predictionend.prediction.stock.ticker_symbol)
      times_ahead = minute_array.select {|minute| minute["date"] >= predictionend.actual_end_time}
      unless times_ahead.empty? 
        min_minute = times_ahead.min_by {|item| item["date"]}
        predictionend.update(actual_end_time:min_minute["date"], actual_end_price:min_minute["close_price"].round(2), end_price_verified:true)
        predictionend.prediction.final_update_score #calculates the final score for the prediction.
        PredictionendMailer.predictioncomplete(predictionend.id).deliver_now #send confirmation email of prediction complete.
      end
      return predictionend #its returned for testing purposes.
    end
  end
end