class GooglenewsWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    ScraperPublic.google_news(ticker_symbol)
  end
end