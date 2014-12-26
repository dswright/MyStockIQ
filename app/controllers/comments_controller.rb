class CommentsController < ApplicationController


	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user

		#Sets up hash of comment attributes to be used when @comment object is created later
		comment = comment_params

		#for a comment from the users page.
		#there could also be comments from the stock page, a prediction details page, or another comment.

		
		
		#Obtain stock page information based on form submission
		#@stock = Stock.find_by(ticker_symbol: comment[:ticker_symbol])

		#if @stock != nil
			#@stream_index = @user.streams.build(stock_id: @stock.id, stream_type: "comment")
		#else
			#@stream_index = @user.streams.build(stream_type: "comment")
		#end

		#Create comment object to be inserted into 'Comments' model
		#comment = Comment.new(comment)
		comment = @user.comments.build(comment)

		if comment.valid?
			#Save stream index
			#@stream_index.save

			#Obtain saved stream object 
			#@saved_stream = Stream.first
			
			#Add stream index to @post
			#@comment[:stream_id] = @saved_stream.id

			comment.save
			flash[:success] = "Post Created!"

			#stream_input = {target_type: "user", target_id: "dw"}
			#stream_input = comment.streams.build(stream_input)
			#stream_input.save

			stream_input_array = params[:stream_array].split(",")
			stream_input_array.each do |stream_item|
				#Must add validation of these parameters against existing stock/user ids to prevent hacking.
				stream_elements = stream_item.split(":")
				stream_input = {target_type: stream_elements[0], target_id: stream_elements[1]}
				stream_input = comment.streams.build(stream_input)
				stream_input.save
			end

			stream = Stream.first
			#Redirect back to stock or user page using 'stock_or_user_page' comments helper function 
			redirect_to stock_or_user_page(params[:stream_array])

		else
			redirect_to stock_or_user_page(params[:stream_array])
		end
	end



	private

		#def comment_params
		def comment_params
			#Obtains parameters from 'comment form' in app/views/shared.
			#Permits adjustment of only the 'content' & 'ticker_symbol' columns in the 'comments' model.
			params.require(:comment).permit(:content)
		end

end
