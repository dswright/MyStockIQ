class StreamsController < ApplicationController

	#First Checks if User is logged in
	before_action :logged_in_user

	before_action :correct_user, only: :destroy

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		#Obtain stock page information based on form submission
		@stock = Stock.find_by(ticker_symbol: stream_params[:ticker_symbol])

		@posts = @user.streams

		#Builds 'Streams' object related to current user. This syntax is only required when looking up the 'Streams' model by 'User'
		@post = @user.streams.build(stream_params, stream_type: "Comment")

		#If Post Saves, redirect to stock page or user profile page
		if @post.save
			flash[:success] = "Post created!"

			if @post.ticker_symbol != nil
				redirect_to stock_page(@post)
			else
				redirect_to user_profile
			end

		else

		#If Post doesn't save, render stock or user page directly such that the error messages are shown
			if @post.ticker_symbol != nil
				render '/stocks/show'
			else
				render '/users/show'
			end

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
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'streams' model.
			params.require(:stream).permit(:content, :ticker_symbol)
		end

		def correct_user
			@post = current_user.streams.find_by(id: params[:id])
			redirect_to user_profile if @post.nil?
		end
end

