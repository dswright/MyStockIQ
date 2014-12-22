class Stock < ActiveRecord::Base

  require 'scraper'

  validates :stock,         presence: true

  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}

  #this takes a date in the form of - "2014-12-16 00:00:00 UTC"
  def self.utc_time(date_string)
    utc_time = Time.parse(date_string).getutc.to_time.to_i * 1000
  end

  def self.get_historical_prices(ticker_symbol)
    stock_prices = Stockprice.where(ticker_symbol:ticker_symbol)
    price_array = []
    stock_prices.each do |price|
      utc_time = Stock.utc_time(price.date.to_s)
      price_array << [utc_time, price.close_price]
    end
    price_array.sort_by! {|array| array[0]}
  end

  def self.get_latest_date(price_array)
    utc_time = last_date = price_array.last[0]
  end

  def self.return_date_based_on_days(days, last_utc_date)
    last_utc_date + (days*60*60*24*1000)
  end

  def self.create_x_date_limits(last_utc_date)
    date_hash_array = [
      {name: "1m", x_range_min:Stock.return_date_based_on_days(-31, last_utc_date), x_range_max:Stock.return_date_based_on_days(15, last_utc_date)},
      {name: "3m", x_range_min:Stock.return_date_based_on_days(-90, last_utc_date), x_range_max:Stock.return_date_based_on_days(45, last_utc_date)},
      {name: "6m", x_range_min:Stock.return_date_based_on_days(-180, last_utc_date), x_range_max:Stock.return_date_based_on_days(90, last_utc_date)},
      {name: "1yr", x_range_min:Stock.return_date_based_on_days(-360, last_utc_date), x_range_max:Stock.return_date_based_on_days(180, last_utc_date)},
      {name: "5yr", x_range_min:Stock.return_date_based_on_days(-1825, last_utc_date), x_range_max:Stock.return_date_based_on_days(900, last_utc_date)},
    ]
  end

end

