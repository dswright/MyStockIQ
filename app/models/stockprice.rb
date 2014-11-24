class Stockprice < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  require 'json'


  def self.fetch_new_prices
    Stockprice.delete_all
    remove_appl = Stock.find_by(ticker_symbol:"AAPL")
    remove_appl.date = nil
    remove_appl.daily_stock_price = nil
    remove_appl.daily_volume = nil
    remove_appl.save

    input_prices_array = []
    #pull all tickersymbols that are active.
    Stock.where(active:true).each do |e|
      # set data_set_data = to the "data" array of objects from the quandl json file
      if price_hash_array = Stockprice.get_quandl_data(e[:ticker_symbol],0)
        #for each row of the docs array from the json file
        price_hash_array.each do |price_hash|
          price_hash = Stockprice.save_price(price_hash)
          #if the stock_hash 'saved' field is true, then put the stock hash in the saved array, ortherwise the failed array.
          if price_hash
            Stockprice.update_stock(price_hash)
            input_prices_array << price_hash
          end
        end
      end
    end
    Stockprice.split_stock("AAPL", input_prices_array)

    #retun the saved and inserted stock_array arrays.
    return input_prices_array
  end

  def self.get_quandl_data(ticker_symbol, count)
    #set url = to the quandl json url.
    price_hash_array = []    
    #if the scrape is successful, set the data_string = to the json data if the scrape is successful
    if data_string = self.get_url(ticker_symbol, 0)
      #parse out json file into an object
      data_set = JSON.parse(data_string)
      #re-process the data here so that it's controlled to my format and the structure doesnt leak to other methods
      data_set["data"].each do |row|
        price_hash_array << Stockprice.process_row(ticker_symbol, row)
      end
      return price_hash_array
    else
      #if the scrape failed, increase the count, and loop back 
      #through the function to attemps again. attempt 10 times maximum.
      count = count + 1
      if count >= 10
        #StockMailer.stocks_failed.deliver_now
        return false
      end
      Stock.get_quandl_data(ticker_symbol, count)
    end
  end

  def self.get_url(ticker_symbol, count)
    if count<=10
      begin
        url_open = open("http://www.quandl.com/api/v1/datasets/EOD/#{ticker_symbol}.json?auth_token=sVaP2d6ACjxmP-jM_6V-").read
      rescue
        Stockprice.get_url(ticker_symbol, count+1)
      end
    end
  end

  #isolate the creation of the price_hash based on the rows from the quandl json file.
  def self.process_row(ticker_symbol, row)
    price_hash = {
      ticker_symbol: ticker_symbol,
      date: row[0],
      open_price: row[1],
      close_price: row[4],
      volume: row[5],
      split: row[7]
    }
    return price_hash
  end

  def self.save_price(price_hash)
    if Stockprice.where(ticker_symbol:price_hash[:ticker_symbol], date:price_hash[:date]).empty?
      new_price = Stockprice.new(price_hash)
      if new_price.save
        return price_hash
      end
    end
    return false
  end

  def self.update_stock(price_hash)
    stock = Stock.find_by(ticker_symbol:price_hash[:ticker_symbol])
    if stock.date.nil? || stock.date <= Date.parse(price_hash[:date])
      stock.date = price_hash[:date]
      stock.daily_stock_price = price_hash[:close_price]
      stock.daily_volume = price_hash[:volume]
      stock.save
    end
  end

  def self.split_stock(ticker_symbol, price_hash_array)
    split_array = price_hash_array.select {|a| a[:split] != 1 && a[:ticker_symbol] == ticker_symbol && a[:date] >= Stockprice.split_date_cutoff}
    unless split_array.empty?
      split_array.each do |stock_split|
        Stockprice.where(:ticker_symbol == stock_split[:ticker_symbol]).where("date < ?", stock_split[:date]).each do |stock_to_update|
          stock_to_update.open_price = stock_to_update.open_price/stock_split[:split]
          stock_to_update.close_price = stock_to_update.close_price/stock_split[:split]
          stock_to_update.save
        end
      end
    end
  end

  #the split date cutoff is necessary because it appears that splits 
  #before a certain time were already applied to the stock price data
  def self.split_date_cutoff
    "2008/01/01"
  end
end

