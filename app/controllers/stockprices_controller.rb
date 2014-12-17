class StockpricesController < ApplicationController
  

  #this function runs once to harvest 5 years of data
  def create
    stocks = Stock.where(date:nil, active:true)
      
    stocks.each do |stock|
      HistoricalWorker.perform_async(stock.ticker_symbol)
    end
  end

  def update
    stocks = Stock.where(active:true)
    stocks.each do |stock|
      LatestWorker.perform_async(stock.ticker_symbol)
    end
  end
end
