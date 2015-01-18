class RelationshipsController < ApplicationController

	respond_to :html, :js

	def create
		followed_type = params[:followed_type]

		if followed_type == "User"
			@target = User.find_by(id: params[:followed_id])
		elsif followed_type == "Stock"
			@target = Stock.find_by(id: params[:followed_id])
		else
			false
		end
		
    	current_user.follow(@target)

	end

	def destroy

		#Finds relationship based on params passed through 'shared/unfollow' form
		@relationship = current_user.active_relationships.find_by(followed_id: params[:followed_id], followed_type: params[:followed_type])

		#Finds target object User or Stock
		if @relationship.followed_type == "User"
			@target = User.find_by(id: @relationship.followed_id)
		elsif @relationship.followed_type == "Stock"
			@target = Stock.find_by(id: @relationship.followed_id)
		else
			false
		end


    	current_user.unfollow(@target)

	end
end
