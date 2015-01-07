class LikesController < ApplicationController

  respond_to :html, :js

  def create

    user = current_user

    like = like_params
    @like = user.likes.build(like)
    @like.save

    @like_type = like[:like_type]
    @streamable_type = like[:target_type]
    @streamable_id = like[:target_id]

    if @like_type == "like"
      @streamable_like_change = params[:streamable_likes].to_i + 1
    else
      @streamable_like_change = params[:streamable_dislikes].to_i + 1
    end


  end

  private
    #def comment_params
    def like_params
      #Permits only certain field types through the URL.
      params.require(:like).permit(:like_type, :target_type, :target_id)
    end

end
