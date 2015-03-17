class LikesController < ApplicationController

  respond_to :html, :js

  def create
    user = current_user

    #if there is an existing like, it will be of the opposite type, destroy it.
    existing_like = Like.find_by(likable_type:params[:likable_type], likable_id:params[:likable_id], user_id:user.id)
    if existing_like
      existing_like.destroy
    end


    like = user.likes.build(like_params)
    like.save

    @likable_type = params[:likable_type]
    @likable_id = params[:likable_id]

    
    
  end

  def destroy
    user = current_user
    like = Like.find_by(likable_type:params[:likable_type], likable_id:params[:likable_id], user_id:user.id, like_type:params[:like_type])
    like.destroy

    @likable_type = params[:likable_type]
    @likable_id = params[:likable_id]

    respond_to do |format|
      format.js { render 'likes/create.js.erb' }
    end

  end

  private
    #def comment_params
    def like_params
      #Permits only certain field types through the URL.
      params.permit(:like_type, :likable_type, :likable_id)
    end

end
