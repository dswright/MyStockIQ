require 'test_helper'
require 'scraper'

class ScraperTest < ActiveSupport::TestCase

  test "enough_volume" do
    price_hash_array_for_volume = [
      {"volume" => 1000000},
      {"volume" => 2000000}]
    enough_volume = Scraper.new.enough_volume?(price_hash_array_for_volume)
    assert enough_volume

    price_hash_array_for_volume[0]["volume"] = 0
    enough_volume = Scraper.new.enough_volume?(price_hash_array_for_volume)
    assert_not enough_volume
  end


  #Price Data methods
  test "PriceData - process_csv_file && save_to_db" do
    historic_url = Scraper.new.url_historic("AAPL")
    assert historic_url.is_a? String

    url = Scraper.new.url_latest("AAPL")
    assert url.is_a? String 
    
    price_hash_array = Scraper.process_csv_file(url, PriceData.new, 0, "AAPL", true)
    assert price_hash_array[0]["ticker_symbol"] == "AAPL"
    assert price_hash_array[0]["split"].to_i == 1

    initial_count = Stockprice.all.count
    Scraper.new.save_to_db(price_hash_array, PriceData.new)
    after_count = Stockprice.all.count
    assert after_count>initial_count
  end
   
  #Stock Data methods
  test "StockData - process_csv_file && save_to_db" do
    url_stocks = Scraper.new.url_stock_list(1)
    assert url_stocks.is_a? String

    stock_hash_array = Scraper.process_csv_file(url_stocks, StockData.new, 0, nil, false)
    assert stock_hash_array[0]["ticker_symbol"] == "JBJ"

    initial_count = Stock.all.count
    Scraper.new.save_to_db(stock_hash_array, StockData.new)
    after_count = Stock.all.count
    assert after_count>initial_count
  end

  #PE Ratios methods
  test "PEData - process_csv_file && update_db" do
    small_stock_array = Stock.where(ticker_symbol:"AAPL")
    url_pe_ratios = Scraper.new.url_pe_ratios(small_stock_array)

    assert url_pe_ratios.is_a? String

    pe_hash_array = Scraper.process_csv_file(url_pe_ratios, PEData.new, 0, nil, true)
    assert pe_hash_array[0]["ticker_symbol"] == "AAPL"

    Scraper.update_db(pe_hash_array, PEData.new, 1)
    assert_not Stock.find_by(ticker_symbol:"AAPL").price_to_earnings.nil?
  end

  #Industry methods
  test "IndustryData - process_csv_file && update_db" do
    url_industry_list = Scraper.new.url_industry_list
    assert url_industry_list.is_a? String

    industry_hash_array = Scraper.process_csv_file(url_industry_list, IndustryData.new, 0, nil, false)
    assert industry_hash_array[0]["ticker_symbol"] == "AAPL"

    Scraper.update_db(industry_hash_array, IndustryData.new, 2)
    assert_not Stock.find_by(ticker_symbol:"AAPL").stock_industry.nil?
  end

  test "NewsData - process feed && update_db" do
    url = "https://www.google.co.uk/finance/company_news?q=LNKD&output=rss"
    news_hash_array = Scraper.process_rss_feed(url, NewsData.new, 0, "LNKD", false)
    assert news_hash_array[0]["ticker_symbol"] == "LNKD"

    initial_count = Newsarticle.all.count
    Scraper.new.save_to_db(news_hash_array, NewsData.new)

    after_count = Newsarticle.all.count
    assert after_count > initial_count

  end
end