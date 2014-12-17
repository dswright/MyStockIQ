class StocksWorker
  include Sidekiq::Worker

  def perform(page)
    Stock.fetch_stocks(page)
  end
end