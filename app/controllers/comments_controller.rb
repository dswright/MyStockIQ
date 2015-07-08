class CommentsController < ApplicationController

	def index
		render json: Comment.all
	end

	def show
		respond_to do |f|
			f.json {
				render json: {
					comments: Comment.where(user_id:1)
				}
			}
		end
	end

	def by_id
		render json: Comment.find(params[:id])
	end

	def create
		#Obtain user session information from Session Helper function 'current_user'.
		@user = current_user
		stock = Stock.find_by(ticker_symbol: params[:ticker_symbol])

		#build the comment for input to the db.
		@comment = @user.comments.build(comment_params)
		
		#Add ticker_symbol to content and find '$' and '@' handles in comment content
		tags = @comment.add_tags(stock.ticker_symbol)

		@messages = {}

		if @comment.valid?
			@comment.save

			#Initialize comment's popularity score in Popularity model
			@comment.build_popularity(score:0).save #build the popularity score table item.

			#Build stream items targeting stock and current user
			@comment.streams.create(targetable_id: stock.id, targetable_type: stock.class.name)
			@comment.streams.create(targetable_id: @user.id, targetable_type: @user.class.name)
			#Build additional stream items for comment targeting other stocks or users
			tags.each {|tag| @comment.streams.create(targetable_id: tag.id, targetable_type: tag.class.name)}
			
			@streams = [Stream.where(streamable_type: 'Comment', streamable_id: @comment.id).first] #get this one stream item.
			@messages[:success] = "Comment added!" #gets inserted at top of page with ajax.
		else
			@comment.invalid_content if @comment.content == nil
		end
	

		respond_to do |f|
			f.js
		end
	end

	private
		def comment_params
			params.require(:comment).permit(:content)
		end
end
