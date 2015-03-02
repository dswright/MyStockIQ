class StockpricesController < ApplicationController
require 'graph'
  def show

    @stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])
    @current_user = current_user

    respond_to do |format|
      format.html
      format.json {
        settings = {ticker_symbol: @stock.ticker_symbol, current_user: @current_user}
        graph = Graph.new(settings)
        render json: {
          :my_prediction => graph.my_prediction,
          :predictions => graph.predictions,
          :my_prediction_id => graph.my_prediction_id,
          :prediction_ids => graph.prediction_ids,
          :daily_prices => graph.daily_prices,
          :intraday_prices => graph.intraday_prices 
        }
      }

    end
  end
end
