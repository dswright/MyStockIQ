class Intradayprice < ActiveRecord::Base

  require 'customdate'

  def self.get_intraday_price_array(ticker_symbol)
    stock_prices = Intradayprice.where(ticker_symbol:ticker_symbol).select("date, close_price")
    price_array = []
    unless stock_prices.empty?
      stock_prices.each do |price|
        utc_time = CustomDate.utc_time(price.date.to_s)
        price_array << [utc_time, price.close_price]
      end
      price_array.sort_by! {|array| array[0]}
    end
  end
end
