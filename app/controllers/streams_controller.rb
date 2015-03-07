class StreamsController < ApplicationController

	#CONFIRM IF THESE ARE STILL NECESSARY AND WHAT OTHER VALIDATIONS THE STREAM MODEL NEEDS.
	

	before_action :correct_user, only: :destroy

	def update
			@stream = Stream.find(params[:stream_id])
			
			respond_to do |f|
				f.js { 

			}
		end
	end

end

