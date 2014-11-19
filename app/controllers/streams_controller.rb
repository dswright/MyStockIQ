class StreamsController < ApplicationController

	#First Checks if User is logged in
	before_action :logged_in_user

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@current_user = current_user

		#Builds 'Streams' object related to current user. This syntax is only required when looking up the 'Streams' model by 'User'
		@post = current_user.streams.build(stream_params)

		if @post.save
			flash[:success] = "Post created!"
			redirect_to root_url
		else
			redirect_to root_url
		end
	end

	def destroy
	end

	private

		def stream_params
			params.require(:stream).permit(:content)
		end
end

