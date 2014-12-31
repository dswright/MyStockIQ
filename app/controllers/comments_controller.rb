class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		#assign the permitted comment form values to the comment variable. 
		comment = comment_params
		#build the comment for input to the db.
		comment = @user.comments.build(comment)

		#process the stream input array using the stream_params_process function from the streams helper.
		@streams = []
		stream_params_array = stream_params_process(params[:stream_string])
		stream_params_array.each do |stream_item|
			@streams << comment.streams.build(stream_item)
		end	

		if comment.valid?
			comment.save
			@streams.each {|stream| stream.save}
			flash[:success] = "Post Created!"
			#redirect to the page and id specified by the landing_page param, passed from the page view.
			redirect_to stream_redirect_processor(params[:landing_page])
		else
			render '/stocks/show/'
			#render stock_or_user_page(stream)
		end


	end

	private
		def comment_params
			#Obtains parameters from 'comment form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
			params.require(:comment).permit(:content)
		end
end
