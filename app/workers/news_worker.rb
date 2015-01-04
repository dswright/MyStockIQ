class NewsWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    ScraperPublic.fetch_news(ticker_symbol)
  end
end