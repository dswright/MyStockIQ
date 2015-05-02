class WelcomeController < ApplicationController

  def show
  end

  def create
    params.each do |key, value|
      if value == "stock"
        stock = Stock.find_by(ticker_symbol: key)
        unless current_user.following?(stock)
          current_user.follow(stock)
        end
      end
    end

    redirect_to "/feed"
  end

  
end
