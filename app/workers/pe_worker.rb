class PEWorker
  include Sidekiq::Worker

  def perform(stock_array)
    pe_array = Stock.fetch_pe(stock_array)
    pe_array.each do |pe_array|
      unless pe_array[:price_to_earnings] == "N/A"         
        stock_to_update = Stock.find_by(ticker_symbol:pe_array[:ticker_symbol])
        unless stock_to_update.nil?
          stock_to_update.update(price_to_earnings: pe_array[:price_to_earnings])
        end
      end
    end
    stock_array = nil
    pe_array = nil
    stock_hash = nil
    stock_to_update = nil
  end
end