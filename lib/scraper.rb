require 'open-uri'
require 'csv'
require 'cgi'
require 'rest-client'
require 'customdate'

class ScraperPublic

  def self.google_daily(ticker_symbol, start_date, dups_allowed)
    price_hash_array = []
    end_date = Time.zone.now.strftime("%m-%d-%Y")
    url = "http://www.google.com/finance/historical?q=#{ticker_symbol}&startdate=#{start_date}&enddate=#{end_date}&output=csv&head=false"
    encoded_url = URI.encode(url)
    begin
      if price_hash_array = Scraper.process_csv_file(encoded_url, GoogleDaily.new, ticker_symbol, dups_allowed)
        #if Scraper.new.enough_volume?(price_hash_array)
        Scraper.new.save_to_db(price_hash_array, GoogleDaily.new)
        Scraper.new.update_stock(ticker_symbol, Stockprice)
        #Stockprice.split_stock(ticker_symbol, input_prices_array)
        #else
        #  Scraper.new.update_to_inactive(ticker_symbol)
        #end
      end
    rescue Exception => e
      if e.message =~ /400 Bad Request/ || e.message =~ /404 Not Found/
        Scraper.new.update_to_inactive(ticker_symbol)
      end
    end
  end

  def self.google_intraday(ticker_symbol, days)
    url = URI.encode("http://www.google.com/finance/getprices?i=300&p=#{days}d&f=d,o,h,l,c,v&df=cpct&q=#{ticker_symbol}")
    if daily_hash_array = Scraper.process_csv_file(url, GoogleIntraday.new, ticker_symbol, false, true)
      unless daily_hash_array.empty?
        Scraper.new.save_to_db(daily_hash_array, GoogleIntraday.new)
        Scraper.new.update_stock(ticker_symbol, Intradayprice)
      end
    end
  end

  def self.google_minute(ticker_symbol)
    url = URI.encode("http://www.google.com/finance/getprices?i=60&p=3d&f=d,o,h,l,c,v&df=cpct&q=#{ticker_symbol}")
    return daily_hash_array = Scraper.process_csv_file(url, GoogleIntraday.new, ticker_symbol, true, true)
  end

  def self.google_news(ticker_symbol)
    url = "https://www.google.co.uk/finance/company_news?q=#{ticker_symbol}&output=rss"
    if news_hash_array = Scraper.process_rss_feed(url, GoogleNews.new, 0, ticker_symbol, false)
      unless news_hash_array.empty?
        Scraper.new.save_to_db(news_hash_array, GoogleNews.new)
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

  def self.quandl_allstocks(page)
    stock_array = []
    url = "http://www.quandl.com/api/v2/datasets.csv?source_code=EOD&per_page=300&page=#{page}&auth_token=sVaP2d6ACjxmP-jM_6V-"
    encoded_url = URI.encode(url)
    if stock_hash_array = Scraper.process_csv_file(encoded_url, QuandlAllstocks.new, nil, false)
      unless stock_hash_array.empty?
        Scraper.new.save_to_db(stock_hash_array, QuandlAllstocks.new)
      end
    end
  end

  def self.yahoo_pe(stock_array)
    if encoded_url = Scraper.new.url_pe_ratios(stock_array)
      if pe_hash_array = Scraper.process_csv_file(encoded_url, YahooPE.new, nil, true)
        Scraper.update_db(pe_hash_array, YahooPE.new, 1)
      end
    end
  end

  def self.quandl_industry(stock_array) #pulls the stock industry, and the exchange!
    url = "https://s3.amazonaws.com/quandl-static-content/Ticker+CSV's/Stock+Exchanges/stockinfo.csv"
    encoded_url = URI.encode(url)
    if industry_hash_array = Scraper.process_csv_file(encoded_url, QuandlIndustry.new, nil, false)
      Scraper.update_db(industry_hash_array, QuandlIndustry.new, 2)
    end
  end
end

class Scraper

  def url_pe_ratios(stock_array)
    ticker_string = ""
    stock_array.each do |stock|
      ticker_string = "#{ticker_string}#{stock["ticker_symbol"]}+"
    end
    url = "http://finance.yahoo.com/d/quotes.csv?s=#{ticker_string}&f=|r"
    return URI.encode(url)
  end

  def self.process_csv_file(url, class_with_process, ticker_symbol=nil, dup = true, check_time = false)
    hash_array = []
    time_start = 0
    open(url) do |f|
      f.each_line do |line|
        CSV.parse(line) do |row|
          if check_time == true
            if start_time_row = class_with_process.start_time_row(row)  #this is for the Google intraday scraper, which is funky.
              time_start = start_time_row
            end
            hash_item = class_with_process.data_hash(row, ticker_symbol, time_start)
          else
            hash_item = class_with_process.data_hash(row, ticker_symbol)
          end
          if hash_item
            if dup == true  #the larger historical scrapers allow for dups for input efficiency.
              hash_array << hash_item
            else
              if class_with_process.check_for_dup(hash_item)
                hash_array << hash_item
              end
            end
          end
        end
      end
    end
    return hash_array
  end

  #used only by the news feed.
  def self.process_rss_feed(url, class_with_process, count, ticker_symbol=nil, dup = true) 
    hash_array = []
    begin
      f = RestClient.get url
    rescue Exception => e
      if e.message =~ /400 Bad Request/
        return false
      end
    end
    f2 = f.force_encoding("utf-8")
    feed = Feedjira::Feed.parse f2
    feed.entries.each do |row|
      begin
        hash_item = class_with_process.data_hash(row, ticker_symbol)
        if hash_item
          if dup == true
            hash_array << hash_item
          else
            if class_with_process.check_for_dup(hash_item)
              hash_array << hash_item
            end
          end
        end
      rescue
        next
      end
    end
    return hash_array
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

  def save_to_stream(hash_array) #used by the news scaper.
    hash_array.each do |news_item|
      news_object = Newsarticle.find_by(google_news_id:news_item["google_news_id"])
      target_stock = Stock.find_by(ticker_symbol:news_item["ticker_symbol"])
      new_stream = news_object.streams.build(target_type:"Stock", target_id:target_stock.id)
      new_stream.save
    end
  end

  def self.update_db(hash_array, class_with_process, case_lines) #used by yahoo pe and quandl industry update.
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

  def enough_volume?(price_hash_array) #volume evaluation for google daily scraper. Out of comission at the moment.
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

  def low_volume_days_cutoff
    1000
  end

  def average_volume_cutoff
    10000
  end

  def update_to_inactive(ticker_symbol) #used by the google daily scraper to update invalid stocks.
    stock_to_update = Stock.find_by(ticker_symbol: ticker_symbol)
    stock_to_update.update(active:false)
  end

  #need to make this work for the intraday scraper as well
  def update_stock(ticker_symbol, price_class)  #used by the intraday scraper and daily scraper to update the latest stock price.
    price_list = price_class.where(ticker_symbol:ticker_symbol)
    update_complete = false
    latest_hash = {}
    latest_hash[:date] = Stock.find_by(ticker_symbol:ticker_symbol).date || "0000-01-01" #if the date is nil, plug in a very old date.
    update_true = false
    price_list.each do |price_hash|
      #this updates the price and time of the stock. The latest possible is 21:00, UTC time.
      #The intraday scraper will update to 21:00, but this scraper will run after that one ends,
      #and it will have a time equal to 21:00, so it will overwrite that amount.
      if price_hash.date >= latest_hash[:date]
        latest_hash = {date:price_hash.date, close_price:price_hash.close_price}
        update_complete = true
      end
    end
    if update_complete
      stock_to_update = Stock.find_by(ticker_symbol:ticker_symbol)
      stock_to_update.update(date:latest_hash[:date], daily_stock_price:latest_hash[:close_price])
    end
  end
end

class GoogleIntraday
  def data_hash(row, ticker_symbol, time_start)
    #if the row[0] is less than 1000000, then its just the integer from the google data, if its greater,
    #then its the actual time stamp, and the correct date.
    if row[0].gsub('a','').to_i <= 1000000
      time_start = time_start + row[0].to_i * 5*60 #add 5 minutes per increment. Comes in as utc time zone.
    end
    daily_hash = {
      "ticker_symbol" => ticker_symbol,
      "date" =>  time_start.utc_time,
      "open_price" => row[4].to_f,
      "close_price" => row[1].to_f
    }
    if daily_hash["open_price"] == 0
      return false
    else
      return daily_hash
    end
  end

  def start_time_row(row)
    if row[0].start_with? "a"
      time_start = row[0].gsub('a','').to_i
    else
      false
    end
  end

  def check_for_dup(hash_item)
    ticker_symbol = hash_item["ticker_symbol"]
    date = hash_item["date"]
    if Intradayprice.where(ticker_symbol:ticker_symbol, date:date).exists?
      false
    else
      true
    end
  end

  def all_data_insert(price_array)
    sql = "INSERT INTO intradayprices 
      (ticker_symbol, date, open_price, close_price, created_at, updated_at)
      VALUES #{price_array.join(", ")}"
  end

    #Hash To Insert Strings
  def single_row_insert(price_hash)
    time = Time.zone.now.to_s(:db)
    price_string = "('#{price_hash["ticker_symbol"]}','#{price_hash["date"]}','#{price_hash["open_price"]}','#{price_hash["close_price"]}','#{time}','#{time}')"
  end

end

class GoogleNews
  def data_hash(row, ticker_symbol)
    marker1 = "width:80%;\">"
    marker2 = "</div>"
    summary = row.summary[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    summary = CGI.unescapeHTML(summary)
    summary = summary.gsub("'","''")

    marker1 = "color:#888888;\">"
    marker2 = "</"
    source = row.summary[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m,1]
    source = CGI.unescapeHTML(source)
    source = source.gsub("'","''")

    url = row.url.gsub("'", "''")

    title = CGI.unescapeHTML(row.title)
    title = title.gsub("'","''")
    price_hash = {
      "google_news_id" => row.entry_id,
      "ticker_symbol" => ticker_symbol,
      "title" => title,
      "source" => source,
      "url" => url,
      "summary" => summary,
      "date" => row.published
    }
  end

  def check_for_dup(hash_item)
    if Newsarticle.where(google_news_id:hash_item["google_news_id"]).exists?
      #put in an extra stream check function here..
      existing_article = Newsarticle.find_by(google_news_id:hash_item["google_news_id"])
      NewsData.new.add_one_stream(existing_article, hash_item["ticker_symbol"])
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
      (google_news_id, title, url, summary, date, created_at, updated_at, source)
      VALUES #{news_array.join(", ")}"
  end

  def single_row_insert(news_hash)
    time = Time.zone.now.to_s(:db)
    price_string = "('#{news_hash["google_news_id"]}','#{news_hash["title"]}','#{news_hash["url"]}','#{news_hash["summary"]}','#{news_hash["date"]}','#{time}','#{time}','#{news_hash["source"]}')"
  end

end


class GoogleDaily

  def data_hash(row, ticker_symbol)
    unless row[1] == "Open" #this csv file has headers, this ignores the header line.
      date = Time.zone.parse(row[0].to_s).strftime("20%y-%m-%d 21:00:00")
      return price_hash = {
        "ticker_symbol" => ticker_symbol,
        "date" => date, #date is in the form "1/7/2015", and it converts to date format OK.
        "open_price" => row[1].to_f,
        "close_price" => row[4].to_f,
        "volume" => row[5].to_i,
        "split" => 1
      }
    else
      return false
    end
  end

  def all_data_insert(price_array)
    sql = "INSERT INTO stockprices 
      (ticker_symbol, date, open_price, close_price, volume, split, created_at, updated_at)
      VALUES #{price_array.join(", ")}"
  end

    #Hash To Insert Strings
  def single_row_insert(price_hash)
    time = Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')
    price_string = "('#{price_hash["ticker_symbol"]}','#{price_hash["date"]}','#{price_hash["open_price"]}','#{price_hash["close_price"]}','#{price_hash["volume"]}','#{price_hash["split"]}','#{time}','#{time}')"
  end
end


class QuandlAllstocks

  #the ticker_symbol is for the PriceData dup check, this dup check sets the ticker from the csv row.
  def check_for_dup(hash_item)
    if Stock.where(ticker_symbol:hash_item["ticker_symbol"]).exists?
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
      "active" => true,
      "viewed" => false
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

class YahooPE
  def data_hash(row, ticker_symbol)
    if row[1] == "N/A" #if the ticker_symbol is invalid and yahoo doesn't have the data, it will return 'N/A'
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

class QuandlIndustry
  #the logic of this method is flipped. We want the ticker to exist in order to be added to the array.
  def check_for_dup(hash_item)
    if Stock.where(ticker_symbol:hash_item["ticker_symbol"]).exists?
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
end




#Dead Classes

#class PriceData
 #def check_for_dup(hash_item)
    #date = row[0]
    #if Stockprice.where(ticker_symbol:hash_item["ticker_symbol"], date:hash_item["date"]).exists?
    #  false
    #else
    #  true
    #end
  #end

  #def data_hash(row, ticker_symbol)
  #  price_hash = {
  #    "ticker_symbol" => ticker_symbol,
  #    "date" => row[0],
  #    "open_price" => row[1].to_f,
  #    "close_price" => row[4].to_f,
  #    "volume" => row[5].to_i,
  #   "split" => row[7].to_i
  #  }
  #end

  #def all_data_insert(price_array)
  #  sql = "INSERT INTO stockprices 
  #    (ticker_symbol, date, open_price, close_price, volume, split, created_at, updated_at)
  #    VALUES #{price_array.join(", ")}"
  #end

    #Hash To Insert Strings
  #def single_row_insert(price_hash)
  #  time = Time.now.to_s(:db)
  #  price_string = "('#{price_hash["ticker_symbol"]}','#{price_hash["date"]}','#{price_hash["open_price"]}','#{price_hash["close_price"]}','#{price_hash["volume"]}','#{price_hash["split"]}','#{time}','#{time}')"
  #end

#end

  #Stock Prices Scrapers
  #def self.fetch_historical_prices(ticker_symbol)
  #  price_hash_array = []
  #  encoded_url = Scraper.new.url_prices(ticker_symbol, 1500)
  #  if price_hash_array = Scraper.process_csv_file(encoded_url, PriceData.new, 0, ticker_symbol, true)
  #    if Scraper.new.enough_volume?(price_hash_array)
  #      Scraper.new.save_to_db(price_hash_array, PriceData.new)
  #      Scraper.new.update_stock(ticker_symbol)
        #Stockprice.split_stock(ticker_symbol, input_prices_array)
  #    else
  #      Scraper.new.update_to_inactive(ticker_symbol)
  #    end
  #  end
  #end

  #def self.fetch_recent_prices(ticker_symbol)
  #  price_hash_array = []
  #  encoded_url = Scraper.new.url_prices(ticker_symbol, 20)
  #  if price_hash_array = Scraper.process_csv_file(encoded_url, PriceData.new, 0, ticker_symbol, false)
  #    unless price_hash_array.empty?
  #      Scraper.new.save_to_db(price_hash_array, PriceData.new)
  #      Scraper.new.update_stock(ticker_symbol)
  #    end
  #  end
  #end

#end

