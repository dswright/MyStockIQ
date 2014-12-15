class StockpricesController < ApplicationController
  

  #this function runs once to harvest 5 years of data
  def create
    @prices_array = Stockprice.fetch_new_prices
  end

  def update
    stocks = Stock.where(date:nil, active:true)
      
    stocks.each do |stock|
      HistoricalWorker.perform_async(stock.ticker_symbol)
    end
    stocks = nil
  end
end
