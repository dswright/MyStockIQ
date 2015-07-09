class StreamsController < ApplicationController

	def index
		@streams = Stream.all
		render json: @streams.to_json(include: [:streamable,:targetable])

	end

	def update
			@stream = Stream.find(params[:stream_id])
			
			respond_to do |f|
				f.js { 

			}
		end
	end

end

