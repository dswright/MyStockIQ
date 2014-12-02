class PEWorker
  include Sidekiq::Worker
  sidekiq_options timeout: 60

  def perform(stock_array)
    pe_array = Stock.fetch_pe(stock_array)
    pe_array.each do |pe_array|
      #set the stock hash to be returned to the view based on the tickersymbol in this csv file row
      #this returns an array of parameters
      stock_hash = stock_array.select {|a| a["ticker_symbol"]==pe_array[:ticker_symbol]}
      unless pe_array[:price_to_earnings] == "N/A"         
        stock_to_update = Stock.find_by(ticker_symbol:pe_array[:ticker_symbol])
        unless stock_to_update.nil?
          stock_to_update.update(price_to_earnings: pe_array[:price_to_earnings])
        end
      end
    end
  end
end