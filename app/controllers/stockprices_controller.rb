class StockpricesController < ApplicationController
require 'graph'
  
  def hover_daily
   
    price = Stockprice.find(params[:id])
    stock = Stock.find_by(ticker_symbol:price.ticker_symbol)

    respond_to do |f|
      f.html {
        render :partial => 'stockprices/hover_daily.js.erb', :locals => { price: price, stock:stock, target: stock } #this is working...
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
          :intraday_prices => graph.intraday_prices,
          :predictions => graph.predictions,
          :my_prediction => graph.my_prediction
        }
      }

    end
  end
end
