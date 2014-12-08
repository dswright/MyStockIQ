class HistoricalWorker
  include Sidekiq::Worker

  require 'csv'
  require 'open-uri'
  require 'json'

  def perform()

    stock = Stock.where("date is ? AND active = ?", nil, true).first
    Stockprice.fetch_new_prices("AAPL")
    #Stockprice.fetch_new_prices(stock.ticker_symbol)
    #HistoricalWorker.perform_async()

    #unless stock_hash_array[count].nil?
      #ticker_symbol = stock_hash_array[count]["ticker_symbol"]
      #unless ticker_symbol.nil?
      #  Stockprice.fetch_new_prices(ticker_symbol)
      #end

      #if count + 1 < stock_hash_array.count
      #  HistoricalWorker.perform_async(stock_hash_array, count+1, i)
      #else
      #  QuandlWorker.perform_async(i+1)
      #end
    #end
  end

end