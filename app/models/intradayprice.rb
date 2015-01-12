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

  def self.forward_array(end_time)
    #5 minute increments from the end time...
    #end_time is in utc format.
    #we're going forward.. 3days to eod no matter what.
    #so... that's kind of crap. Need to check if 3 days lands on a weekday or holiday, and jump another day if it does.
    #the dateforward array needs to return an array of 5 minute increments.
    i = 0;
    forward_array = []
    end_of_time = end_time + 3*3600*24*1000

    iterations = (3*3600*24)/(5*60) #total time divided by 5 minutes to get total 5 minute itterations. 
    #Don't actually want these iterations, but it was a start..

    while i<=iterations do
      time_spot = end_of_time + i*5*60*1000
      if CustomDate.check_if_out_of_time(time_spot)
        iterations += 1
      else
        forward_array << [time_spot, "null"]
      end
      i += 1
    end
    return forward_array
  end
end
