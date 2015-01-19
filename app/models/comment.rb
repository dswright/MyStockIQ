class Comment < ActiveRecord::Base

	belongs_to :user
  	has_many :streams, as: :streamable

	validates :content, presence: true, length: { maximum: 140}
	default_scope -> { order(created_at: :desc) }

	def update_popularity_score


		#calculate score of comment itself
		self.popularity_score = self.likes - self.dislikes
		#set score equal to zero if negative
		self.popularity_score = 0 if self.popularity_score < 0

		#obtain array of replies to comments
		replies = self.replies

		unless replies.empty?
			replies.each do |reply|

				#Find all additional replies attached to 'reply', and add them to 'replies' array
				reply.replies.each {|reply| replies << reply}

				self.popularity_score += (reply.likes - reply.dislikes)
			end
		end

		self.save
		return self.popularity_score 
	end

	def likes
		likes = Like.where(like_type: "like", target_id: self.id).count
	end

	def dislikes
		dislikes = Like.where(like_type: "dislike", target_id: self.id).count
	end

	def replies
		reply_stream = Stream.where(target_id: self.id, target_type: "Comment")
		replies = []
		reply_stream.each do |stream|
			replies << Comment.find_by(id: stream.streamable_id)
		end

		return replies
	end

end
