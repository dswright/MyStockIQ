class StockpricesController < ApplicationController
require 'graph'
  
  def hover_daily

    the_id = params[:id].to_s =~ /\A[-+]?\d*\.?\d+\z/  #checks to see if the id is number or string. Returns 0 or nil.
    price_data = {}

    

    if the_id == 0  #if the_id = 0, then the param is a number.
      price = Stockprice.find(params[:id])
      price_data[:price] = price.close_price
      price_data[:date] = price.date
      stock = Stock.find_by(ticker_symbol:price.ticker_symbol)
    else
      stock = Stock.find_by(ticker_symbol:params[:id])
      price_data[:price] = stock.daily_stock_price
      price_data[:date] = stock.date
    end

    respond_to do |f|
      f.html {
        render :partial => 'stockprices/hover_daily.js.erb', :locals => { price: price_data, stock:stock, target: stock } #this is working...
      }
    end

  end

   def hover_intraday
    price = Intradayprice.find(params[:id])
    stock = Stock.find_by(ticker_symbol:price.ticker_symbol)

    respond_to do |f|
      f.html {
        render :partial => 'stockprices/hover_intraday.js.erb', :locals => { :price =>  price, stock:stock, target: stock } #this is working...
      }
    end
  end


  def show

    @stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])
    @current_user = current_user

    respond_to do |format|
      format.html
      format.json {
        settings = {ticker_symbol: @stock.ticker_symbol, current_user: @current_user, start_point:"stocks"}
        graph = Graph.new(settings)
        render json: { #graphLines need to be in the correct numerical order to be set correctly.
          :daily_prices => graph.daily_prices,
          :intraday_prices => graph.intraday_prices
          # :my_prediction => graph.my_prediction,
          # :predictions => graph.predictions,
          # :my_prediction_id => graph.my_prediction_id,
          # :prediction_ids => graph.prediction_ids,
          
          # :daily_price_ids => graph.daily_price_ids,
          # :intraday_price_ids => graph.intraday_price_ids,
          # 
        }
      }

    end
  end
end
