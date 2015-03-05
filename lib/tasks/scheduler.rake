require 'rake'
require 'scraper'
require 'customdate'

namespace :scraper do

  #Google Data Rakes
  task :google_daily_historical => :environment do
    start_date = "01-01-2010"
    dups_allowed = true
    stocks = Stock.where(active:true) 
    stocks.each do |stock|
      GoogledailyWorker.perform_async(stock.ticker_symbol, start_date, dups_allowed)
    end
  end

  task :google_daily_recent => :environment do
    dups_allowed = false
    start_date = 5.days.ago.in_time_zone.strftime("%m-%d-%Y")
    stocks = Stock.where(active:true) 
    stocks.each do |stock|
      GoogledailyWorker.perform_async(stock.ticker_symbol, start_date, dups_allowed)
    end
  end

  task :quandl_allstocks => :environment do
    x = 30
    1.upto(30) do |i|
      QuandlallstocksWorker.perform_async(i)
    end
  end

  task :yahoo_pe => :environment do
    stock_array = Stock.where(active:true)
    sliced = stock_array.each_slice(199).to_a
    sliced.each do |small_stock_array|
      small_array = []
      small_stock_array.each do |single_stock|
        small_array << {"ticker_symbol" => single_stock.ticker_symbol}
      end
      YahoopeWorker.perform_async(small_array)
    end
  end

  task :quandl_industry => :environment do
    stock_array = Stock.where(active:true)
    QuandlindustryWorker.perform_async(stock_array)
  end

  task :google_news => :environment do
    stocks = Stock.where(viewed:true)
    stocks.each do |stock|
      GooglenewsWorker.perform_async(stock.ticker_symbol)
    end
  end

  task :google_intradayprices => :environment do
    #only run this task during the schedule stock market hours
    d = Time.zone.now
    #est sets the utc time back 5 hours to get it into est. 
    #Subtract additional 10 minutes to time for Google data to populate.
    utc_time = d.utc_time_int - 10*60
    if utc_time.valid_stock_time?
      stocks = Stock.where(viewed:true)
      stocks.each do |stock|
        GoogleintradayWorker.perform_async(stock.ticker_symbol, 6) #look 6 days back for intraday data.
      end
    end
  end
end

namespace :predictions do
  #this no longer seems necessary...
  task :prediction_start => :environment do
    time_now = Time.zone.now
    predictions = Prediction.where("start_time < ?", time_now).where(start_price_verified:false)
    predictions.each do |prediction|
      PredictionstartWorker.perform_async(prediction.id)
    end
  end

  task :prediction_end => :environment do
    predictions = Prediction.where(start_price_verified:false)
    predictions.each do |prediction|
      PredictionstartWorker.perform_async(prediction.id)
    end

    predictions = Prediction.where(active:true)
    predictions.each do |prediction|
      prediction.exceeds_end_price #if the stock price exceeds the prediction price, move date and set to active:false, create prediction end and stream items.
      prediction.exceeds_end_time #if the current time exceeds the prediction end time, set active:false, create prediction ends, and stream items.
      prediction.update_score #run an update of the current score.
    end

    #checks predictionends where the end price is not verified. A prediction end will be created when the prediction is de-activated.
    Predictionend.where(end_price_verified:false).each do
      PredictionendWorker.perform_async(predictionend.id) #updates the predictionend to verified status.
    end
  end
end

namespace :updates do
  task :update_popularity => :environment do
    Newsarticle.all.each do |article|
      if article.popularity == nil
        HelperWorker.perform_async(article.id)
      end
    end
  end

  task :update_streams => :environment do
    Stream.all.each do |stream|
      stream.targetable_type = stream.target_type
      stream.targetable_id = stream.target_id
      stream.save
    end
  end
end

  #run all of this in the same worker and same rake task...
# 1. Check for predictions to verify start times. Done!
# 2. Check for predictions to verify end times and end the prediction.
# 2. Regularly re-score current predictions based on current stock prices.
# 3. Check for predictions to cancel due to price exceeding.
# 4. Send prediction confirmation email when prediction is ended.


#DEAD RAKE TASKS, NO LONGER IN SERVICE
#Price Data Rakes
  #task :fetch_historical_prices => :environment do
  #  stocks = Stock.where(date:nil, active:true) 
  #  stocks.each do |stock|
  #    HistoricalWorker.perform_async(stock.ticker_symbol)
  #  end
  #end

  #task :fetch_recent_prices => :environment do
  #  stocks = Stock.where(active:true)
  #  stocks.each do |stock|
  #    LatestWorker.perform_async(stock.ticker_symbol)
  #  end
  #end

