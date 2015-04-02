class RepliesController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#Obtain parent information from stream_reply_form
		@parent_stream = Stream.find(params[:stream_id])
		


		#build the reply object for input to the db.
		@reply = @user.replies.build(reply_params)
		@reply.repliable_id = params[:repliable_id]
		@reply.repliable_type = params[:repliable_type]

		response_msgs = []

		if @reply.valid?
			@reply.save
			@reply.build_popularity(score: 0).save

			response_msgs << "Posted reply!"
		else 
			response_msgs << "Invalid post"
		end
		@response = response_maker(response_msgs)

		respond_to do |f|
			f.js
		end
	end

	private
	def reply_params
		#Obtains parameters from '_stream_reply_form' in app/views/stream.
		#Permits adjustment of only the 'content' column in the 'replies' model.
		params.require(:reply).permit(:content)
	end
end
