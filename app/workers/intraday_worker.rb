class IntradayWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stock_id, days)
    ScraperPublic.fetch_intradayprices(ticker_symbol, days)
  end

end