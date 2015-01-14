class StockGraph
  require 'customdate'

  def self.get_daily_price_array(ticker_symbol)
    stock_prices = Stockprice.where(ticker_symbol:ticker_symbol).select("date, close_price")
    price_array = []
    stock_prices.each do |price|
      utc_time = CustomDate.utc_date_string_to_utc_date_number(price.date)
      price_array << [utc_time, price.close_price]
    end
    price_array.sort_by! {|array| array[0]}
  end
 
  def self.return_date_based_on_days(last_utc_date, days)
    last_utc_date + (days*60*60*24*1000)
  end

  def self.find_y_min(price_array, start_time, end_time)
    limited_array = price_array.select{|price| price[0] >= start_time && price[0]<=end_time}
    min_item = limited_array.min_by {|item| item[1]}
    return min_item[1]
  end

  def self.get_intraday_price_array(ticker_symbol)
    stock_prices = Intradayprice.where(ticker_symbol:ticker_symbol).select("date, close_price")
    price_array = []
    unless stock_prices.empty?
      stock_prices.each do |price|
        utc_time = CustomDate.utc_date_string_to_utc_date_number(price.date)
        price_array << [utc_time, price.close_price]
      end
      price_array.sort_by! {|array| array[0]}
    end
  end

  def self.intraday_forward_array(end_time)
    #returns an array of time time and price variables.
    #used to look into the future on the graph.
    #intraday forward array currently looks ahead 3 days arbitrarily. 
    #The actual target setting is controlled with the x axis settings.

    i = 0;
    forward_array = []

    iterations = (3*3600*6.5)/(5*60) + 2 #the 1000 is not here because it gets divided out.
    #total time divided by 5 minutes to get total 5 minute itterations. 
    
    #6.5 hours used because that is how long the market is open for.
    while i<=iterations do
      time_spot = end_time + i*5*60*1000
      if CustomDate.check_if_out_of_time(time_spot)
        iterations += 1
      else
        forward_array << [time_spot, 220]
      end
      i += 1
    end
    return forward_array
  end

end

class StockGraphPublic
  def self.create_x_date_limits(daily_array, intraday_array)
    last_utc_date_daily = daily_array.last[0]
    last_utc_date_intraday = intraday_array.last[0]
    array_details_intraday = [{name:"1d", start:6.5, finish:3.25}, #
                     {name:"5d", start:6.5*5, finish:6.5*2.5}] #finish will adjust the end time used on the x axis. 
                     #The date_forward_array will always be set to 3 days ahead, so setting this value to more than 3 days
                     #will have minimal affect.

    array_details_daily = [{name:"1m", start:20*6.5, finish:10*6.5},
                     {name:"3m", start:60*6.5, finish:30*6.5},
                     {name:"6m", start:120*6.5, finish:60*6.5},
                     {name:"1yr", start:240*6.5, finish:120*6.5},
                     {name:"5yr", start:1200*6.5, finish:600*6.5}]

    date_hash_array = []

    array_details_intraday.each do |detail|
      start_time = CustomDate.valid_start_point(last_utc_date_intraday,  60*5*1000, detail[:start]*3600*1000)
      end_time = CustomDate.valid_end_point(last_utc_date_intraday, 60*5*1000, detail[:finish]*3600*1000)

      date_hash_array << {name: detail[:name],
                          x_range_min:start_time, 
                          x_range_max:end_time,
                          y_range_min:StockGraph.find_y_min(intraday_array, start_time, end_time)
                        }
    end

    #this part needs to be fixed to use the new formulas and shit. But we need new stock data first.
    array_details_daily.each do |detail|
      start_time = StockGraph.return_date_based_on_days(last_utc_date_daily, detail[:start])
      end_time = StockGraph.return_date_based_on_days(last_utc_date_daily, detail[:finish])
      date_hash_array << {name: detail[:name], 
                          x_range_min:start_time, 
                          x_range_max:end_time,
                          y_range_min:StockGraph.find_y_min(daily_array, start_time, end_time)
                        }
    end
    return date_hash_array
  end
end
