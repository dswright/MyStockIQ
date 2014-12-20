class StocksWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(page)
    ScraperPublic.fetch_stocks(page)
  end
end