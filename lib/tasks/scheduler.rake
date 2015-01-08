require 'rake'
require 'scraper'

namespace :scraper do

  #Stock Rakes
  task :fetch_stocks => :environment do
    x = 30
    1.upto(30) do |i|
      StocksWorker.perform_async(i)
    end
  end

  task :fetch_stocks_pe => :environment do
    stock_array = Stock.where(active:true)
    sliced = stock_array.each_slice(199).to_a
    sliced.each do |small_stock_array|
      small_array = []
      small_stock_array.each do |single_stock|
        small_array << {"ticker_symbol" => single_stock.ticker_symbol}
      end
      PEWorker.perform_async(small_array)
    end
  end

  task :fetch_stocks_industry => :environment do
    stock_array = Stock.where(active:true)
    IndustryWorker.perform_async(stock_array)
  end

  #Price Data Rakes
  task :fetch_historical_prices => :environment do
    stocks = Stock.where(date:nil, active:true) 
    stocks.each do |stock|
      HistoricalWorker.perform_async(stock.ticker_symbol)
    end
  end

  task :fetch_recent_prices => :environment do
    stocks = Stock.where(active:true)
    stocks.each do |stock|
      LatestWorker.perform_async(stock.ticker_symbol)
    end
  end

  task :fetch_news => :environment do
    stocks = Stock.where(active:true)
    stocks.each do |stock|
      NewsWorker.perform_async(stock.ticker_symbol)
    end
  end

  task :fetch_intradayprices => :environment do
    d = Time.now.utc
    eastern_time = d.in_time_zone('Eastern Time (US & Canada)')
    weekday = eastern_time.wday
    hour = eastern_time.strftime("%H:%M")
    hour_split = hour.split(":")
    hour_num = (hour_split[0] * 60) + hour_split[1]
    #between the eastern hours of 9:28 am and 4:12 pm run the intraday scraper.
    if hour_num >=  567 && hour_num <= 972
      if weekday != 6 && weekday != 0
        stocks = Stock.where(viewed:true)
        stocks.each do |stock|
          IntradayWorker.perform_async(stock.ticker_symbol, 1)
        end
      end
    end
  end

end

