class RelationshipsController < ApplicationController

	def create
		followed_type = params[:followed_type]

		if followed_type == "User"
			target = User.find_by(id: params[:followed_id])
		elsif followed_type == "Stock"
			target = Stock.find_by(id: params[:followed_id])
		else
			false
		end
		
    	current_user.follow(target)
    	redirect_to request.referrer || login_path
	end

	def destroy
		followed_type = params[:followed_type]
		
		if followed_type == "User"
			target = User.find_by(id: params[:followed_id])
		elsif followed_type == "Stock"
			target = Stock.find_by(id: params[:followed_id])
		else
			false
		end

    	current_user.unfollow(target)
    	redirect_to request.referrer || login_path
	end
end
