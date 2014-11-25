class StreamsController < ApplicationController

	#First Checks if User is logged in
	before_action :logged_in_user

	before_action :correct_user, only: :destroy

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		@posts = @user.streams

		#Builds 'Streams' object related to current user. This syntax is only required when looking up the 'Streams' model by 'User'
		@post = @user.streams.build(stream_params)

		if @post.save
			flash[:success] = "Post created!"
			redirect_to user_profile
		else
			render '/users/show'

		end
	end

	def destroy
		# 'post' variable is set by 'correct_user' method
		@post.destroy
		flash[:success] = "Post deleted"
		redirect_to user_profile
	end 

	private

		def stream_params
			#Obtains parameters from 'stream form' in app/views/shared.
			#Permits adjustment of only the 'content' column in the 'streams' model.
			params.require(:stream).permit(:content)
		end

		def correct_user
			@post = current_user.streams.find_by(id: params[:id])
			redirect_to user_profile if @post.nil?
		end
end

