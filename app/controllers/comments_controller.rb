class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		#build the comment for input to the db with the comment_params method.
		comment = @user.comments.build(comment_params)

		#process the stream input array using the stream_params_process function from the streams helper.
		streams = []
		stream_params_array = stream_params_process(params[:stream_string])
		stream_params_array.each do |stream_item|
			streams << comment.streams.build(stream_item)
		end	

		response_msgs = []
		if comment.valid?
			comment.save
			streams.each {|stream| stream.save}
			#create the stream item to load in the ajax.
			#it doesn't matter which stream item for this comment is loaded, just that one loads.
			if params[:parent] #what to do when it is a reply.
				stream = Stream.where(streamable_type: 'Comment', streamable_id: comment.id).first
				@stream_hash_array = Stream.stream_maker([stream], params[:nest_count].to_i + 1) #gets inserted below the response item, with proper indent.
				response_msgs << "Comment added!" #gets inserted at top of page with ajax.
				@parent = params[:parent]
				@comment = Comment.new
				@like = Like.new
			else #what to do when it is a regular comment.
				stream = Stream.where(streamable_type: 'Comment', streamable_id: comment.id).first
				@stream_hash_array = Stream.stream_maker([stream], 0) #gets inserted to top of stream with ajax.
				response_msgs << "Comment added!" #gets inserted at top of page with ajax.
				@comment = Comment.new
				@like = Like.new
			end
		else
			response_msgs << "Comment invalid." #gets inserted at top of page with ajax.
		end
		
		@response = response_maker(response_msgs)

		respond_to do |f|
			f.js { 
				if params[:parent]
				 render "reply.js.erb"
				else 
					render "create.js.erb"
				end 
			}
		end

	end



	private
		def comment_params
			#Obtains parameters from 'comment form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
			params.require(:comment).permit(:content)
		end
end
