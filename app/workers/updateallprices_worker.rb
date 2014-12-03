class PricesupdateWorker
  include Sidekiq::Worker
  sidekiq_options timeout: 60

  def perform
    Stock.where(active:true).each do |stock|
      Updateoneprice_worker.perform_async(stock.ticker_symbol)
    end
  end
end