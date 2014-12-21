class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#Sets up hash of comment attributes to be used when @comment object is created later
		@comment_params = comment_params
		
		#Obtain stock page information based on form submission
		@stock = Stock.find_by(ticker_symbol: @comment_params[:ticker_symbol])

		if @stock != nil
			@stream_index = @user.streams.build(stock_id: @stock.id, stream_type: "comment")
		else
			@stream_index = @user.streams.build(stream_type: "comment")
		end

		#Create comment object to be inserted into 'Comments' model
		@comment = Comment.new(@comment_params)

		if @comment.valid?
			#Save stream index
			@stream_index.save

			#Obtain saved stream object 
			@saved_stream = Stream.first
			
			#Add stream index to @post
			@comment[:stream_id] = @saved_stream.id

			@comment.save
			flash[:success] = "Post Created!"

			#Redirect back to stock or user page using 'stock_or_user_page' stock helper function 
			redirect_to stock_or_user_page(@comment)
		else
			render stock_or_user_view(@comment)
		end
	end



	private

		#def comment_params
		def comment_params
			#Obtains parameters from 'stream form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
		#	params.require(:comment).permit(:content, :ticker_symbol)
		#end
			params.require(:comment).permit(:content, :ticker_symbol)
		end

end
