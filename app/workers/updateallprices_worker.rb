class PricesupdateWorker
  include Sidekiq::Worker
  require 'date'

  def perform
    stock = Stock.where("updated_at <= ?", DateTime.now.to_date).where(active:true).first
    
    PricesupdateWorker.perform_async(stock.ticker_symbol)
  end
end