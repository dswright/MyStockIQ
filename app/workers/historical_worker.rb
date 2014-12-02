class HistoricalWorker
  include Sidekiq::Worker
  sidekiq_options timeout: 60
  require 'csv'
  require 'open-uri'
  require 'json'

  def perform(ticker_symbol)
    Stockprice.fetch_new_prices(ticker_symbol)
  end

end