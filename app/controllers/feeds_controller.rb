class FeedsController < ApplicationController
  before_action :redirect_non_user, only: :show

  def show

    respond_to do |format| 

      @current_user = current_user
      #sets @predictions for the view, and for making stream.
      @predictions = @current_user.predictions.where(active:true)

      #sets @predictions for the view, and for making stream.
      @historical_predictions = @current_user.predictions.where(active:false).reorder("score desc").limit(5)

      #Top 10 popular stocks
      @popular_stocks = Stock.popular_stocks(10)

      #this is the tricky line. The stream needs to be built well.
      @streams = Stream.feed(@current_user).by_popularity_score.paginate(page: params[:page], per_page: 10)

      format.html{
      }

      format.js{
      }
    end
  end
end
