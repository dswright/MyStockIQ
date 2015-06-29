class FeedsController < ApplicationController
  
  #Function to pull the whole stock file and then update all records.
  #Run daily
  #def create
  # StocksWorker.perform_async
  #end

  def show
    return if user_logged_in? #redirects the user to the login page if they are not logged in.

    respond_to do |format| 

      @current_user = current_user
      #sets @predictions for the view, and for making stream.
      @predictions = @current_user.predictions.where(active:true)

      #sets @predictions for the view, and for making stream.
      @historical_predictions = @current_user.predictions.where(active:false).reorder("score desc").limit(5)

      #Top 10 popular stocks
      @popular_stocks = Stock.popular_stocks(10)

      #this is the tricky line. The stream needs to be build well.
      #first one for now is all things that the user is directly related in, like the user page.

      @streams = Stream.feed(@current_user).by_popularity_score.paginate(page: params[:page], per_page: 10)

      format.html{

      }

      format.js{

      }
    end
  end
end
