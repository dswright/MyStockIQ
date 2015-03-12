#this is a file to write random functions for one time modifications.

class HelperWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    stockprices = Stockprice.where(ticker_symbol:ticker_symbol).reorder("date Desc").limit(1501)
    stockprices.each_with_index do |stockprice, index|
      unless index == stockprices.count - 1 #if this is the last row of data, dont run the update.
        previous_price = stockprices[index+1].close_price
        daily_percent_change = ((stockprice.close_price/previous_price -1)*100).round(2)
        stockprice.daily_percent_change = daily_percent_change
        stockprice.save
      end
    end
  end
end