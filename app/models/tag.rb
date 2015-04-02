class Tag < ActiveRecord::Base

	belongs_to :tagable, polymorphic: true

	#Iterates through and adds tags to all comments
	def tag_comments
		Stream.find_each do |stream|

			#If stream comment is targeting stock, keep track of ticker_symbol for tagging.
			#This will not be used if streamable type is not a comment. 
			if stream.target_type == "Stock"
				ticker_symbol = stream.targetable.ticker_symbol
			else
				ticker_symbol = nil
			end

			#If stream is comment, then add tags to comment.
			if stream.streamable_type == "Comment"
				stream.streamable.add_tag(ticker_symbol)
			end
		end
	end
end
