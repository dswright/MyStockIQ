class Popularity < ActiveRecord::Base
  #declares a polymorphic association for the streams table. 
  belongs_to :popularable, polymorphic: true

  validates :score, presence: :true, numericality: :true

  	def update_score

	  	net_likes = (self.popularable.likes_count - self.popularable.dislikes_count)

	  	#obtain array of replies to comments
		replies = self.popularable.replies

		unless replies.empty?
			replies.each do |reply|

				#Find all additional replies attached to 'reply', and add them to 'replies' array
				reply.replies.each {|reply| replies << reply}

				net_likes += (reply.likes_count - reply.dislikes_count)
			end
	  	end

	  	net_likes = 1 if net_likes <=0
		score = Math.log(net_likes)

		#For prediction posts, addtional points are awarded for prediction score
		if self.popularable.class.name == "Prediction"
			prediction_score = self.popularable.score
			#10 times prediction score is added to popularity score
			score += prediction_score
		end

		#Reduce popularity score 1 point per half day
		score -= (Time.zone.now - self.created_at)/(60*60*12)

		self.score = score.round(6)

		self.save

		return self.score
	end

end
