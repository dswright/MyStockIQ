class IndustryWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stock_array)
    ScraperPublic.fetch_stocks_industry(stock_array)    
  end
end