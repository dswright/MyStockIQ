class StreamsController < ApplicationController

	def index

		@streams = Stream.where(targetable_id: params[:id], targetable_type: params[:type]).reorder("id asc")
		#render json: @streams.to_json(include: {streamable: {include: :user}, targetable: {}})

	end

	def new
		params = stream_params
		@stream = Stream.new(params)
		@stream.save
	end

	def update
			@stream = Stream.find(params[:stream_id])
			
			respond_to do |f|
				f.js { 

			}
		end
	end


	private

		def stream_params
			params.require(:stream).permit(:targetable_type, :targetable_id, :streamable_type, :streamable_id)
		end
end

