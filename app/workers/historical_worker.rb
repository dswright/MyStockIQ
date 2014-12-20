class HistoricalWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    ScraperPublic.fetch_historical_prices(ticker_symbol)
  end
end