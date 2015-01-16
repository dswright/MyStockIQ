class GoogledailyWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol, start_date, dups_allowed)
    ScraperPublic.google_daily(ticker_symbol, start_date, dups_allowed)
  end
end