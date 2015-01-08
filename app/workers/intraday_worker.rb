class IntradayWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol, days)
    ScraperPublic.fetch_intradayprices(ticker_symbol, days)
  end

end