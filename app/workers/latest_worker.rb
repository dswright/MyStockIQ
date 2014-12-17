class LatestWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    ScraperPublic.fetch_recent_prices(ticker_symbol)
  end

end