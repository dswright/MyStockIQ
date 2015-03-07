class FeedsController < ApplicationController
  
  #Function to pull the whole stock file and then update all records.
  #Run daily
  #def create
  # StocksWorker.perform_async
  #end

  def show
    return if user_logged_in? #redirects the user to the login page if they are not logged in.

    @current_user = current_user
    #sets @predictions for the view, and for making stream.
    @predictions = @current_user.predictions.where(active:true)

    #sets @predictions for the view, and for making stream.
    @historical_predictions = @current_user.predictions.where(active:false).order("score DESC")


    #this is the tricky line. The stream needs to be build well.
    #first one for now is all things that the user is directly related in, like the user page.
    @streams = @current_user.streams.limit(40)

    unless @streams == nil
      #@streams.each {|stream| stream.update_stream_popularity_scores}

      #this line makes sorts the stream by popularity score.
      #@streams = @streams.sort_by {|stream| stream.streamable.popularity_score}

      #streams = sort_by_popularity(streams)
      #@streams = @streams.reverse
      
      #Stock's posts, comments, and predictions to be shown in the view
      #will_paginate in view automatically generates params[:page]
      @streams = @streams.paginate(page: params[:page], per_page: 10)
      #@stream_hash_array = Stream.stream_maker(@streams, 0)
    end
  end
end
