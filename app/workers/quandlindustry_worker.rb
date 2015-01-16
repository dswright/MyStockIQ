class QuandlindustryWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(stock_array)
    ScraperPublic.quandl_industry(stock_array)    
  end
end