class PEWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stock_array)
    ScraperPublic.fetch_stocks_pe(stock_array)
  end
end