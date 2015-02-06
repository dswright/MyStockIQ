class PredictionstartWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    minute_array = ScraperPublic.google_minute(prediction.stock.ticker_symbol)
    times_ahead = minute_array.select {|minute| minute["date"] >= prediction.start_time}
    unless times_ahead.empty? 
      min_minute = times_ahead.min_by {|item| item["date"]}
      prediction.update(start_time:min_minute["date"], start_price:min_minute["close_price"].round(2), start_price_verified:true)
    end
    return prediction #this return is only necessary for the test to pass.
  end
end