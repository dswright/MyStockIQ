class RepliesController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		@parent_stream = Stream.find(params[:stream_id])

		#build the reply object for input to the db.
		@reply = @user.replies.build(reply_params)
		@reply.popularity_score = 0.0

		#Obtain parent information from stream_reply_form
		parent = {id: params[:parent_id], type: params[:parent_type]}

		#build the stream object for input to the db.
		stream = @reply.streams.build( streamable_type: @reply.class.name, streamable_id: @reply.id, target_type: parent[:type], target_id: parent[:id])

		response_msgs = []

		if @reply.valid?
			@reply.save
			stream.save
			response_msgs << "Posted reply!"
		else 
			response_msgs << "Invalid post"
		end
		@response = response_maker(response_msgs)

		respond_to do |f|
			f.js { 
			}
		end
	end

	private
	def reply_params
		#Obtains parameters from '_stream_reply_form' in app/views/stream.
		#Permits adjustment of only the 'content' column in the 'replies' model.
		params.require(:reply).permit(:content)
	end
end
