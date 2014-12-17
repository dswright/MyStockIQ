require 'test_helper'
require 'scraper'

class StockTest < ActiveSupport::TestCase

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
    assert stock_hash_array[0]["ticker_symbol"] == "DFVL"

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
=begin
  test "IndustryData - process_csv_file && update_db" do
    url_industry_list = Scraper.new.url_industry_list
    assert url_industry_list.is_a? String

    industry_hash_array = Scraper.process_csv_file(url_industry_list, IndustryData.new, 0, nil, false)
    assert industry_hash_array[0]["ticker_symbol"] == "AAPL"

    Scraper.update_db(industry_hash_array, IndustryData.new, 2)
    assert_not Stock.find_by(ticker_symbol:"AAPL").stock_industry.nil?
  end
=end

end

  #test "should return array with pe ratio" do
  #  pe_update_array = Stock.fetch_pe(@successful_inserted_stock_array)
  #  assert_not pe_update_array[0][:price_to_earnings].empty?
  #end

  #test "worker - should return array with PE ratio" do
  #  PEWorker.new.perform(@successful_inserted_stock_array)
  #  assert_not Stock.find_by(ticker_symbol:"BNNY").price_to_earnings.nil?
  #end

  #test "worker - should return array with industry" do
  #  IndustryWorker.new.perform(@successful_inserted_stock_array)
  #  assert_not Stock.find_by(ticker_symbol:"BNNY").stock_industry.nil?
  #end

  #test "worker - should work when pe ratio cant be found" do
  #  PEWorker.new.perform(@no_pe_stock_array)
  #  assert Stock.find_by(ticker_symbol:"blah").price_to_earnings.nil?
  #end




