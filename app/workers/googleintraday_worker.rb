class GoogleintradayWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol, days)
    ScraperPublic.google_intraday(ticker_symbol, days)
  end

end