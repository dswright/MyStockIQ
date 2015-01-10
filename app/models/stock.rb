class Stock < ActiveRecord::Base

  require 'customdate'

  validates :stock,         presence: true

  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}

  

  def self.get_daily_price_array(ticker_symbol)
    stock_prices = Stockprice.where(ticker_symbol:ticker_symbol).select("date, close_price")
    price_array = []
    stock_prices.each do |price|
      utc_time = CustomDate.utc_time(price.date.to_s)
      price_array << [utc_time, price.close_price]
    end
    price_array.sort_by! {|array| array[0]}
  end
 
  def self.return_date_based_on_days(days, last_utc_date)
    last_utc_date + (days*60*60*24*1000)
  end

  def self.start_time_for_day(last_utc_date_intraday, days_back)
    date_string = CustomDate.utc_time_to_string(last_utc_date_intraday)
    day = date_string.beginning_of_day
    morning_time = CustomDate.utc_time(day.to_s) + (days_back*60*60*24*1000) + ((1.5*60*60)*1000)
    return morning_time
  end

  def self.end_time_for_day(last_utc_date_intraday)
    date_string = CustomDate.utc_time_to_string(last_utc_date_intraday)
    day = date_string.beginning_of_day
    closing_time = CustomDate.utc_time(day.to_s) + ((8*60*60)*1000)
    return closing_time
  end

  def self.find_y_min(price_array, start_time, end_time)
    limited_array = price_array.select{|price| price[0] >= start_time && price[0]<=end_time}
    min_item = limited_array.min_by {|item| item[1]}
    return min_item[1]
  end

  def self.create_x_date_limits(daily_array, intraday_array)
    last_utc_date_daily = daily_array.last[0]
    last_utc_date_intraday = intraday_array.last[0]
    array_details_intraday = [{name:"1d", start:0},
                     {name:"5d", start:-7}]

    array_details_daily = [{name:"1m", start:-31, finish:15},
                     {name:"3m", start:-90, finish:45},
                     {name:"6m", start:-180, finish:90},
                     {name:"1yr", start:-360, finish:180},
                     {name:"5yr", start:-1825, finish:900}]

    date_hash_array = []

    array_details_intraday.each do |detail|
      start_time = Stock.start_time_for_day(last_utc_date_intraday, detail[:start])
      end_time = Stock.end_time_for_day(last_utc_date_intraday)

      date_hash_array << {name: detail[:name],
                          x_range_min:start_time, 
                          x_range_max:end_time,
                          y_range_min:Stock.find_y_min(intraday_array, start_time, end_time)
                        }
    end

    array_details_daily.each do |detail|
      start_time = Stock.return_date_based_on_days(detail[:start], last_utc_date_daily)
      end_time = Stock.return_date_based_on_days(detail[:finish], last_utc_date_daily)
      date_hash_array << {name: detail[:name], 
                          x_range_min:start_time, 
                          x_range_max:end_time,
                          y_range_min:Stock.find_y_min(daily_array, start_time, end_time)
                        }
    end
    return date_hash_array

  end
end

