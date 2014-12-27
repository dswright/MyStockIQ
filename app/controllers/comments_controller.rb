class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		#assign the permitted comment form values to the comment variable. 
		comment = comment_params
		#build the comment for input to the db.
		comment = @user.comments.build(comment)
		#process the stream input array 
		stream_params_array = stream_params_process(params[:stream_string])
		if comment.valid?
			comment.save
			flash[:success] = "Post Created!"
			stream_params_array.each do |stream_item|
				stream_input = comment.streams.build(stream_input)
				stream_input.save
			end
		end
		#redirect to the first target item defined by the comments form. First item should be the page the comment is coming from.
		redirect_to stock_or_user_page(stream_params_array[0])
	end

	private
		def comment_params
			#Obtains parameters from 'comment form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
			params.require(:comment).permit(:content)
		end
end
