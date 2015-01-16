class QuandlallstocksWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(page)
    ScraperPublic.quandl_allstocks(page)    
  end
end