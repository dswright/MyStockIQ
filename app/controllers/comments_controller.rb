class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#build the comment for input to the db.
		comment = @user.comments.build(comment_params)

			

		response_msgs = []
		if comment.valid?
			comment.save

			comment.build_popularity(score:0).save #build the popularity score table item.

			#process the stream input array using the stream_params_process function from the streams helper.
			streams = []
			stream_params_array = stream_params_process(params[:stream_string])
			stream_params_array.each do |stream_item|
				comment.streams.build(stream_item).save
			end
			
			@streams = [Stream.where(streamable_type: 'Comment', streamable_id: comment.id).first] #get this one stream item.
			response_msgs << "Comment added!" #gets inserted at top of page with ajax.
		else
			response_msgs << "Comment invalid." #gets inserted at top of page with ajax.
		end
		
		@response = response_maker(response_msgs)

		respond_to do |f|
			f.js
		end
	end

	private
		def comment_params
			#Obtains parameters from 'comment form' in app/views/shared.
			#Permits adjustment of only the 'content' column in the 'comments' model.
			params.require(:comment).permit(:content)
		end
end
