class PricesupdateWorker
  include Sidekiq::Worker
  require 'date'
  sidekiq_options timeout: 60

  def perform
    stock = Stock.where("updated_at <= ?", DateTime.now.to_date+1).where(active:true).first
    
    PricesupdateWorker.perform_async(stock.ticker_symbol)
    end
  end
end