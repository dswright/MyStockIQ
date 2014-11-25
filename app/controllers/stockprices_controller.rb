class StockpricesController < ApplicationController
  
  #this function runs everyday.
  def update
  end

  #this function runs once to harvest 5 years of data
  def create
    @prices_array = Stockprice.fetch_new_prices
  end


end
