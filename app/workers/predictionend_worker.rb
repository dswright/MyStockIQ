class PredictionstartWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    minute_array = ScraperPublic.google_minute(prediction.stock.ticker_symbol)
    times_ahead = minute_array.select {|minute| minute["date"] >= prediction.end_time}
    unless times_ahead.empty? 
      min_minute = times_ahead.min_by {|item| item["date"]}
      prediction.update(end_time:min_minute["date"], end_price:min_minute["close_price"].round(2), end_price_verified:true)
      #run function here to recalculate score of this prediction.
      #for prediction cancellations, set the end time to the closes valid market minute, then when that time passes
      #that final score calculation will be run.
      #similar with the prediction hitting the target price, the end_time gets moved forward when the stock price is higher than the prediction price.
      #the rake task needs to execute the function that also checks to see if there is a stock price higher than a prediction target.
          
    end
  end
end