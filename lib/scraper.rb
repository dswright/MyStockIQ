class ScraperPublic

  def self.fetch_news(ticker_symbol)
    url = "https://www.google.co.uk/finance/company_news?q=#{ticker_symbol}&output=rss"
    if news_hash_array = Scraper.process_rss_feed(url, NewsData.new, 0, ticker_symbol, false)
      unless news_hash_array.empty?
        Scraper.new.save_to_db(news_hash_array, NewsData.new)
        #need something tha tprocesses the comment for targets.
        #and also something that makes a stream relation based on the tickersymbol
        #if that relation does not already exist.
        #something in the check dup function?
        #another check up function?
        Scraper.new.save_to_stream(news_hash_array)
        #Scraper.new.save_to_stream(stream_hash_array, NewsData.new)
      end
    end
  end

  #Stock Scrapers
  def self.fetch_stocks(page)
    stock_array = []
    if encoded_url = Scraper.new.url_stock_list(page)
      if stock_hash_array = Scraper.process_csv_file(encoded_url, StockData.new, 0, nil, false)
        unless stock_hash_array.empty?
          Scraper.new.save_to_db(stock_hash_array, StockData.new)
        end
      end
    end
  end

  def self.fetch_stocks_pe(stock_array)
    if encoded_url = Scraper.new.url_pe_ratios(stock_array)
      if pe_hash_array = Scraper.process_csv_file(encoded_url, PEData.new, 0, nil, true)
        Scraper.update_db(pe_hash_array, PEData.new, 1)
      end
    end
  end

  def self.fetch_stocks_industry(stock_array)
    encoded_url = Scraper.new.url_industry_list
    if industry_hash_array = Scraper.process_csv_file(encoded_url, IndustryData.new, 0, nil, false)
      Scraper.update_db(industry_hash_array, IndustryData.new, 2)
    end
  end

  #Stock Prices Scrapers
  def self.fetch_historical_prices(ticker_symbol)
    price_hash_array = []
    if encoded_url = Scraper.new.url_historic(ticker_symbol)
      if price_hash_array = Scraper.process_csv_file(encoded_url, PriceData.new, 0, ticker_symbol, true)
        if Scraper.new.enough_volume?(price_hash_array)
          Scraper.new.save_to_db(price_hash_array, PriceData.new)
          Scraper.new.update_stock(ticker_symbol)
          #Stockprice.split_stock(ticker_symbol, input_prices_array)
        else
          Scraper.new.update_to_inactive(ticker_symbol)
        end
      end
    end
  end

  def self.fetch_recent_prices(ticker_symbol)
    price_hash_array = []
    if encoded_url = Scraper.new.url_latest(ticker_symbol)
      if price_hash_array = Scraper.process_csv_file(encoded_url, PriceData.new, 0, ticker_symbol, false)
        unless price_hash_array.empty?
          Scraper.new.save_to_db(price_hash_array, PriceData.new)
          Scraper.new.update_stock(ticker_symbol)
        end
      end
    end
  end

end

class Scraper
  require 'open-uri'
  require 'csv'
  require 'cgi'

  #Available Scraper URLs
  def url_latest(ticker_symbol)
    rows_of_data = 15
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

  def url_pe_ratios(stock_array)
    ticker_string = ""
    stock_array.each do |stock|
      ticker_string = "#{ticker_string}#{stock["ticker_symbol"]}+"
    end
    url = "http://finance.yahoo.com/d/quotes.csv?s=#{ticker_string}&f=|r"
    return_encoded_url(url,0)
  end

  def url_industry_list
    url = "https://s3.amazonaws.com/quandl-static-content/Ticker+CSV's/Stock+Exchanges/stockinfo.csv"
    return_encoded_url(url, 0)
  end

  def return_encoded_url(url, count)
    return URI.encode(url)
  end

  def self.process_csv_file(url, class_with_process, count, ticker_symbol=nil, dup = true)
    if count <= 10
      begin
        hash_array = []
        open(url) do |f|
          f.each_line do |line|
            CSV.parse(line) do |row|
              hash_item = class_with_process.data_hash(row, ticker_symbol)
              if hash_item
                if dup == true
                  hash_array << hash_item
                else
                  if class_with_process.check_for_dup(row, ticker_symbol)
                    hash_array << hash_item
                  end
                end
              end
            end
          end
        end
        return hash_array
      rescue
        Scraper.process_csv_file(url, class_with_process, count+1, ticker_symbol, dup)
      end
    end  
    return false
  end

  def self.process_rss_feed(url, class_with_process, count, ticker_symbol=nil, dup = true)
    if count <= 2
      begin
        hash_array = []
        feed = Feedjira::Feed.fetch_and_parse(url)
        feed.entries.each do |row|
          begin
            hash_item = class_with_process.data_hash(row, ticker_symbol)
            if hash_item
              if dup == true
                hash_array << hash_item
              else
                if class_with_process.check_for_dup(row, ticker_symbol)
                  hash_array << hash_item
                end
              end
            end
          rescue
            next
          end
        end        
        return hash_array
      rescue
        Scraper.process_rss_feed(url, class_with_process, count+1, ticker_symbol, dup)
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

  def save_to_stream(hash_array)
    hash_array.each do |news_item|
      news_object = Newsarticle.find_by(google_news_id:news_item["google_news_id"])
      target_stock = Stock.find_by(ticker_symbol:news_item["ticker_symbol"])
      new_stream = news_object.streams.build(target_type:"Stock", target_id:target_stock.id)
      new_stream.save
    end
  end


  def self.update_db(hash_array, class_with_process, case_lines)
    case_array = []
    case_array2 = []
    where_array = []
    hash_array.each do |hash|
      new_line = class_with_process.create_case_line(hash)
      if new_line
        case_array << new_line
      end
      where_line = class_with_process.create_where_line(hash)
      if where_line
        where_array << where_line
      end

      if (case_lines == 2)
        new_line = class_with_process.create_case_line2(hash)
        if new_line
          case_array2 << new_line
        end
      end
      

    end
    unless case_array.empty?
      if case_lines != 2
        sql = class_with_process.all_data_update(case_array, where_array)
        ActiveRecord::Base.connection.execute(sql)
      else
        sql = class_with_process.all_data_update(case_array, where_array, case_array2)
        ActiveRecord::Base.connection.execute(sql)
      end
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

class NewsData
  def data_hash(row, ticker_symbol)
    marker1 = "width:80%;\">"
    marker2 = "</div>"
    summary = row.summary[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    summary = CGI.unescapeHTML(summary)
    summary = summary.gsub("'","''")

    title = CGI.unescapeHTML(row.title)
    title = title.gsub("'","''")
    price_hash = {
      "google_news_id" => row.entry_id,
      "ticker_symbol" => ticker_symbol,
      "title" => title,
      "url" => row.url,
      "summary" => summary,
      "date" => row.published
    }
  end

  def check_for_dup(row,ticker_symbol=nil)
    if Newsarticle.where(google_news_id:row.entry_id).exists?
      #put in an extra stream check function here..
      existing_article = Newsarticle.find_by(google_news_id:row.entry_id)
      NewsData.new.add_one_stream(existing_article, ticker_symbol)
      false
    else
      true
    end
  end

  def add_one_stream(existing_article, ticker_symbol)
    stock_id_of_ticker_symbol = Stock.find_by(ticker_symbol:ticker_symbol).id
    unless Stream.where(streamable_type:"Newsarticle", streamable_id:existing_article.id).exists?
      add_stream = existing_article.streams.build(target_type:"Stock", target_id:stock_id_of_ticker_symbol)
      add_stream.save
    end
  end

  def all_data_insert(news_array)
    sql = "INSERT INTO newsarticles 
      (google_news_id, title, url, summary, date, created_at, updated_at)
      VALUES #{news_array.join(", ")}"
  end

  def single_row_insert(news_hash)
    time = Time.now.to_s(:db)
    price_string = "('#{news_hash["google_news_id"]}','#{news_hash["title"]}','#{news_hash["url"]}','#{news_hash["summary"]}','#{news_hash["date"]}','#{time}','#{time}')"
  end

end

class PriceData

  def check_for_dup(row,ticker_symbol=nil)
    date = row[0]
    if Stockprice.where(ticker_symbol:ticker_symbol, date:date).exists?
      false
    else
      true
    end
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

  #the ticker_symbol is for the PriceData dup check, this dup check sets the ticker from the csv row.
  def check_for_dup(row, ticker_symbol=nil)
    ticker_symbol = row[0].gsub(/EOD\//,"")
    if Stock.where(ticker_symbol:ticker_symbol).exists?
      false
    else
      true
    end
  end

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
    price_string = "('#{stock_hash["stock"]}','#{stock_hash["ticker_symbol"]}',#{stock_hash["active"]},'#{time}','#{time}')"
  end
end

class PEData
  def data_hash(row, ticker_symbol)
    if row[1] == "N/A"
      return false
    else
      pe_hash = {
        "ticker_symbol" => row[0],
        "price_to_earnings" => row[1]
      }
    end
  end

  def all_data_update(pe_case_array, pe_where_array)
    sql = "update stocks 
            SET price_to_earnings = CASE ticker_symbol
              #{pe_case_array.join("\n")}
            END
          WHERE ticker_symbol IN (#{pe_where_array.join(", ")})"
  end

  def create_case_line(data_hash)
    return "WHEN '#{data_hash["ticker_symbol"]}' THEN #{data_hash["price_to_earnings"]}"
  end

  def create_where_line(data_hash)
    return "'#{data_hash["ticker_symbol"]}'"
  end
end

class IndustryData

  #the logic of this method is flipped. We want the ticker to exist in order to be added to the array.
  def check_for_dup(row, ticker_symbol=nil)
    csv_ticker = row[0].gsub('.','_').gsub('/','_').gsub('-','_')
    if Stock.where(ticker_symbol:csv_ticker).exists?
      true
    else
      false
    end
  end

  def data_hash(row, ticker_symbol)
    if (row[4] == "Stock no longer trades")
      return false
    else
      csv_ticker = row[0].gsub('.','_').gsub('/','_').gsub('-','_')
      industry_hash = {
        "ticker_symbol" => csv_ticker, 
        "stock_industry" => row[3], 
        "exchange" => row[4]
      }
      return industry_hash
    end
  end

  def all_data_update(industry_case_array, industry_where_array, exchange_case_array)
    sql = "update stocks 
            SET stock_industry = CASE ticker_symbol
              #{industry_case_array.join("\n")}
            END,
             exchange = CASE ticker_symbol
              #{industry_case_array.join("\n")}
            END

          WHERE ticker_symbol IN (#{industry_where_array.join(", ")})"
  end

  def create_case_line(data_hash)
    return "WHEN '#{data_hash["ticker_symbol"]}' THEN '#{data_hash["stock_industry"]}'"
  end

  def create_case_line2(data_hash)
    return "WHEN '#{data_hash["ticker_symbol"]}' THEN '#{data_hash["exchange"]}'"
  end

  def create_where_line(data_hash)
    return "'#{data_hash["ticker_symbol"]}'"
  end 
    
          #add this row of the csv file to the array to return
end
