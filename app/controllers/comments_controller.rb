class CommentsController < ApplicationController

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		@comment_params = comment_params
		
		#Obtain stock page information based on form submission
		@stock = Stock.find_by(ticker_symbol: @comment_params[:ticker_symbol])

		if @stock != nil
			@stream_index = @user.streams.build(stock_id: @stock.id, stream_type: "comment")
		else
			#Update stream table with stock id and 'comment' label
			@stream_index = @user.streams.build(stream_type: "comment")
		end

		#Update comment table with parameters passed from stream form
		@comment = Comment.new(comment_params)


		if @comment.valid?
			#Save stream index
			@stream_index.save

			#Add stream index to @post
			@comment[:stream_id] = Stream.first

			@comment.save
			flash[:success] = "Post Created!"
			#stock_or_user_page() function in comments helper returns stock or user page path
			redirect_to stock_or_user_page(@comment)

		else
			#stock_or_user_view() function in comments helper returns stock or user view path
			render stock_or_user_view(@comment)
		end

	end

	def show

	end

	private

		def comment_params
			#Obtains parameters from 'stream form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
			params.require(:comment).permit(:content, :ticker_symbol)
		end
end
