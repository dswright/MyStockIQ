module PopularityPast

  	def has_replies?
  		count = Stream.where(target_id: self.id, target_type: self.class.name).count
  		if count > 0
  			return true
  		else 
  			return false
  		end
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

		#obtain array of replies to comments
		replies = self.replies

		unless replies.empty?
			replies.each do |reply|

				#Find all additional replies attached to 'reply', and add them to 'replies' array
				reply.replies.each {|reply| replies << reply}

				net_likes += (reply.likes - reply.dislikes)
			end
		end

		net_likes = 1 if net_likes <=0
		popularity_score = Math.log(net_likes)

		#For prediction posts, addtional points are awarded for prediction score
		if self.class.name == "Prediction"
			prediction_score = self.score
			#10 times prediction score is added to popularity score
			popularity_score += prediction_score
		end
 	
		#Reduce popularity score 1 point per half day
		popularity_score -= (Time.zone.now - self.created_at)/(60*60*12)


		self.popularity_score = popularity_score.round(6)

		self.save

		return self.popularity_score 
	end



end