class LikesController < ApplicationController

  respond_to :html, :js

  def create

    user = current_user

    like = like_params
    @like = user.likes.build(like)
    @like.save

    if @like_type == "like"
      @updated_likes = params[:likes].to_i + 1
    else
      @updated_likes = params[:dislikes].to_i + 1
    end


  end

  private
    #def comment_params
    def like_params
      #Permits only certain field types through the URL.
      params.require(:like).permit(:like_type, :likable_type, :likable_id)
    end

end
