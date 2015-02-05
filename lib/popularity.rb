module Popularity

	def likes
    	likes = Like.where(like_type: "like", target_id: self.id, target_type:self.class.name).count
  	end

  	def dislikes
    	dislikes = Like.where(like_type: "dislike", target_id: self.id, target_type:self.class.name).count
  	end

  	def replies
    	reply_stream = Stream.where(target_id: self.id, target_type: self.class.name)
    	replies = []
    	reply_stream.each do |stream|
        #this limits all replies to being comments, which is not the case.
        #predictionends are replies to the original prediction.
      		replies << Comment.find_by(id: stream.streamable_id)
    	end

    	return replies
  	end

  	def update_popularity_score


  		net_likes = (self.likes - self.dislikes)
     	net_likes = 1 if net_likes <= 0

		#calculate score of comment itself
		popularity_score = Math.log(net_likes)

		#obtain array of replies to comments
		replies = self.replies

		unless replies.empty?
			replies.each do |reply|

				#Find all additional replies attached to 'reply', and add them to 'replies' array
				reply.replies.each {|reply| replies << reply}

				net_likes = (reply.likes - reply.dislikes)
          		net_likes = 1 if net_likes <= 0

				popularity_score += Math.log(net_likes)
			end
		end

		#For prediction posts, addtional points are awarded for prediction score
		if self.class.name == "Prediction"
			prediction_score = self.score
			#10 times prediction score is added to popularity score
			popularity_score += prediction_score
		end
 	
		#Reduce popularity score 1 point per half day
		popularity_score -= (Time.zone.now - self.created_at)/(60*60*12)

		#Minimum popularity score is 0
		#popularity_score = 0.0 if popularity_score < 0

		self.popularity_score = popularity_score.round(3)

		self.save

		return self.popularity_score 
	end



end