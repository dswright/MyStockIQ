class HistoricalWorker
  include Sidekiq::Worker
  sidekiq_options timeout: 60
  require 'csv'
  require 'open-uri'
  require 'json'

  def perform(stock_hash_array, count)
    ticker_symbol = stock_hash_array[count][:ticker_symbol]
    unless ticker_symbol.nil?
      Stockprice.fetch_new_prices(ticker_symbol)
    end

    if count <= stock_hash_array.count
      HistoricalWorker.perform_async(stock_hash_array, count+1)
    end
  end

end