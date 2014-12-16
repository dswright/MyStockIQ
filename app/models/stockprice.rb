class Stockprice < ActiveRecord::Base
  #require 'scraper'

  def self.fetch_historical_prices(ticker_symbol)
    price_hash_array = []
    if encoded_url = Scraper.new.url_historic(ticker_symbol)
      if price_hash_array = Scraper.process_csv_file(encoded_url, PriceData.new, 0, ticker_symbol)
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

end

