class Scraper
  require 'open-uri'
  require 'csv'

  #Available Scraper URLs
  def url_latest(ticker_symbol)
    rows_of_data = 5
    url = "http://www.quandl.com/api/v1/datasets/EOD/#{ticker_symbol}.csv?exclude_headers=true&rows=#{rows_of_data}&auth_token=sVaP2d6ACjxmP-jM_6V-"
    return_encoded_url(url, 0)
  end

  def url_historic(ticker_symbol)
    rows_of_data = 1500
    url = "http://www.quandl.com/api/v1/datasets/EOD/#{ticker_symbol}.csv?exclude_headers=true&rows=#{rows_of_data}&auth_token=sVaP2d6ACjxmP-jM_6V-"
    return_encoded_url(url, 0)
  end

  def url_stock_list(page)
    url = "http://www.quandl.com/api/v2/datasets.csv?source_code=EOD&per_page=300&page=#{page}&auth_token=sVaP2d6ACjxmP-jM_6V-"
    return_encoded_url(url,0)
  end

  def return_encoded_url(url, count)
    if count<=10
      begin
        return url_open = URI.encode(url)
      rescue
        return_encoded_url(url, count+1)
      end
    end
    return false
  end

  def self.process_csv_file(url, class_with_process, count, ticker_symbol=nil)
    if count <= 10
      begin
        hash_array = []
        open(url) do |f|
          f.each_line do |line|
            CSV.parse(line) do |row|
            #row = line.split(",")
              hash_array << class_with_process.data_hash(row, ticker_symbol)
            end
          end
        end
        return hash_array
      rescue
        Scraper.process_csv_file(url, class_with_process, count+1, ticker_symbol)
      end
    end  
    return false
  end

  def save_to_db(hash_array, class_with_process)
    structured_array = []
    hash_array.each do |hash|
      structured_array << class_with_process.single_row_insert(hash)
    end
    unless structured_array.empty?
      sql = class_with_process.all_data_insert(structured_array)
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def enough_volume?(price_hash_array)
    low_volume_count = 0
    volume_sum = 0
    price_hash_array.each do |price_hash|
      if price_hash["volume"].nil?
        return false
      elsif price_hash["volume"] == 0
        return false
      else
        volume_sum += price_hash["volume"]
        if price_hash["volume"] <= low_volume_days_cutoff
          low_volume_count +=1
        end
      end
      if low_volume_count >= 30
        return false
      end
    end
    if volume_sum/price_hash_array.count <= average_volume_cutoff
      return false
    else
      return true
    end
  end

  def update_to_inactive(ticker_symbol)
    stock_to_update = Stock.find_by(ticker_symbol: ticker_symbol)
    stock_to_update.update(active:false)
  end

  def update_stock(ticker_symbol)
    price_list = Stockprice.where(ticker_symbol:ticker_symbol)
    latest_date = Date.parse('01-01-0000')
    update_complete = false
    latest_daily_stock_price = 0
    latest_daily_volume = 0
    price_list.each do |price_hash|
      if price_hash.date > latest_date
        latest_date = price_hash.date
        latest_daily_stock_price = price_hash.close_price
        latest_daily_volume = price_hash.volume
        update_complete = true
      end
    end
    if update_complete
      stock_to_update = Stock.find_by(ticker_symbol:ticker_symbol)
      stock_to_update.date = latest_date
      stock_to_update.daily_stock_price = latest_daily_stock_price
      stock_to_update.daily_volume = latest_daily_volume
      stock_to_update.save
    end
    pricelist = nil
    latest_date = nil
  end

  def low_volume_days_cutoff
    1000
  end

  def average_volume_cutoff
    10000
  end

  #the split date cutoff is necessary because it appears that splits 
  #before a certain time were already applied to the stock price data
  def split_date_cutoff
    "1996/01/01"
  end

end


class PriceData

  def so_simple
    puts "workingggg"
  end

  def data_hash(row, ticker_symbol)
    price_hash = {
      "ticker_symbol" => ticker_symbol,
      "date" => row[0],
      "open_price" => row[1].to_f,
      "close_price" => row[4].to_f,
      "volume" => row[5].to_i,
      "split" => row[7].to_i
    }
  end

  def all_data_insert(price_array)
    sql = "INSERT INTO stockprices 
      (ticker_symbol, date, open_price, close_price, volume, split, created_at, updated_at)
      VALUES #{price_array.join(", ")}"
  end

    #Hash To Insert Strings
  def single_row_insert(price_hash)
    time = Time.now.to_s(:db)
    price_string = "('#{price_hash["ticker_symbol"]}','#{price_hash["date"]}','#{price_hash["open_price"]}','#{price_hash["close_price"]}','#{price_hash["volume"]}','#{price_hash["split"]}','#{time}','#{time}')"
  end
end

class StockData

  def data_hash(row, ticker_symbol)
    code = row[0].gsub(/EOD\//,"")
    #remove this string from the stock name to get a clean name.
    real_name = row[1].gsub(/ \(#{code}\) Stock Prices, Dividends and Splits/,"")
    real_name = real_name.gsub("'","''")
    #set stock_hash
    stock_hash = { 
      "stock" => real_name,
      "ticker_symbol" => code,
      "active" => true
    }
  end

  def all_data_insert(stock_array)
    sql = "INSERT INTO stocks 
      (stock,ticker_symbol,active,updated_at,created_at)
      VALUES #{stock_array.join(", ")}"
  end

    #Hash To Insert Strings
  def single_row_insert(stock_hash)
    time = Time.now.to_s(:db)
    price_string = "('#{stock_hash["stock"]}','#{stock_hash["ticker_symbol"]}',#{stock_hash["ticker_symbol"]},'#{time}','#{time}')"
  end

end