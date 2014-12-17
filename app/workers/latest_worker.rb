class LatestWorker
  include Sidekiq::Worker

  def perform(ticker_symbol)
    Stockprice.fetch_recent_prices(ticker_symbol)
  end

end