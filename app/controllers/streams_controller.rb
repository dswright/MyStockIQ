class StreamsController < ApplicationController

	def update
			@stream = Stream.find(params[:stream_id])
			
			respond_to do |f|
				f.js { 

			}
		end
	end

end

