class StocksController < ApplicationController
require 'graph'
require 'scraper'

  before_action :redirect_non_user, only: :show

	
	#Function to pull the whole stock file and then update all records.
	#Run daily
	#def create
	#	StocksWorker.perform_async
	#end

	def show
    respond_to do |format|

        @stock = Stock.find_by(ticker_symbol:params[:ticker_symbol])

        @current_user = current_user

      format.html {
        
        #include for format.html and format.js only.
        @streams = @stock.streams.by_popularity_score.paginate(page: params[:page], per_page: 10)


        #if a stock gets viewed, update the stocks table so that the stock gets real time stock data.
        if (@stock.viewed == false)
          days = 6
          ScraperPublic.google_intraday(@stock.ticker_symbol, days)
          @stock.update(viewed:true)
        end

     		#creates prediction variable to be used to set up the prediction creation form (see app/views/shared folder)
      	@prediction = @current_user.predictions.build(stock_id: @stock.id, prediction_end_price: nil) #this empty form variable will get overwritten if the page exists.

      	#If active prediction exists, show active prediction
      	if @prediction.active_prediction_exists?
      		@prediction = Prediction.find_by(user_id: @current_user.id, stock_id: @stock.id, active: true)
      	  
          #if my_prediction exists, run these updates on the prediction so it is up to date.
          @prediction.exceeds_end_price #if the stock price exceeds the prediction price, move date and set to active:false, create prediction end and stream items.
          @prediction.exceeds_end_time #if the current time exceeds the prediction end time, set active:false, create prediction ends, and stream items.
          @prediction.update_score #run an update of the current score.

          @predictionend = @prediction.build_predictionend()
          @prediction_end_input_page = "stockspage" #for the prediction details box, set the input page for the prediction cancel button.

        end

        #Determines relationship between current user and target user
        @target = @stock



      	@comment_stream_string = "Stock:#{@stock.id},User:#{@current_user.id}"
      	@prediction_stream_string = "Stock:#{@stock.id},User:#{@current_user.id}"



        
        @graph_buttons = ["1D", "5D", "1M", "3M", "6M", "1Yr", "5Yr"]
        #used by the view to generate the html buttons

        gon.ticker_symbol = @stock.ticker_symbol
        @price_point = Stockprice.where(ticker_symbol:@stock.ticker_symbol).reorder("date desc").limit(1)[0]
      }
      
      format.json { #this is the json response to the search bar queries.

        stock_data = []
        Stock.where(active:true).where("UPPER(ticker_symbol) like UPPER(?)", params[:ticker_symbol]).each do |stock|
          stock_data << [stock.ticker_symbol, stock.stock]
        end
        Stock.where(active:true).where("UPPER(ticker_symbol) like UPPER(?)", "%#{params[:ticker_symbol]}%").limit(10).each do |stock|
          stock_data << [stock.ticker_symbol, stock.stock]
        end

        render json: { #this is data rendered for the the search bar.
          :stock_data => stock_data
        }
      }

      format.js {
        #used to respond to the infinite scroll
        @streams = @stock.streams.by_popularity_score.paginate(page: params[:page], per_page: 10)
      }
    end

	end
end
