module PopularityPast

	def likes_count
		self.likes.where(like_type: "like").count
	end

	def dislikes_count
		self.likes.where(like_type: "dislike").count
	end

  	def has_replies?
  		count = Stream.where(target_id: self.id, target_type: self.class.name).count
  		if count > 0
  			return true
  		else 
  			return false
  		end
  	end



end