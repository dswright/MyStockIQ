class PEWorker
  include Sidekiq::Worker

  def perform(stock_array)
    Stock.fetch_stocks_pe(stock_array)
  end
end