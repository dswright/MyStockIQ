class PricesupdateWorker
  include Sidekiq::Worker
  sidekiq_options timeout: 60

  def perform(ticker_symbol)
    
    
    
  end
end