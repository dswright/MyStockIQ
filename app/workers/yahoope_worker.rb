class YahoopeWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stock_array)
    ScraperPublic.yahoo_pe(stock_array)
  end
end