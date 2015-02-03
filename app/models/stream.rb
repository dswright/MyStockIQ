class Stream < ActiveRecord::Base


  #declares a polymorphic association for the streams table. 
  belongs_to :streamable, polymorphic: true

  #has_many :comments, dependent: :destroy
  #has_many :predictions, dependent: :destroy
  #uses Rails default_scope function to sort the posts such that the most recent one is first.
  default_scope -> {order('created_at DESC')}

  ######### STREAM MODEL VALIDATIONS ##########

  #Stream.valid? returns TRUE when:

  	#user_id exists
  	#validates :user_id, presence: true

  	#content exists and has a max length of 140 characters
  	#validates :content, presence: true, length: {maximum: 140}


  def self.stream_maker(stream, nest_count)
    stream_hash_array = []
    stream.each do |stream_item|
      #begin making the hash immediately, making the parent item the first item in the array? Or just the sub comments?
      #the original array is just a list of stream items.. can that be sustained?
      #yes, it could still pass back a significantly different looking array item.
      #needs a recurrsive loop to go through this.
      #like [array_item, nest_count, sub_array, popularity_score],[array_item, nest_count, sub_array, popularity_score]
      sub_array = []
      
      
      #the streamable_type and streamable_id will be the way to find the children of this stream item.
      sub_array = Stream.where(target_type: stream_item.streamable_type, target_id: stream_item.streamable_id)
      unless sub_array.empty?
        sub_array = Stream.stream_maker(sub_array, nest_count+1)
      end

      #this table does not exist yet, but it will. Should this just be a calculation? An amalgomation of comments + votes?? 
      #No. Spread over too many tables. It is technically calculatable, but inconvenient.
      #popularity_score = Popularity.where(target_type: stream_item.streamable_type, target_id: stream_item.streamable_id)
      popularity_score = 0 #for now.

      hash_form = {
        stream: stream_item, 
        nest_count: nest_count, 
        sub_hash_array: sub_array, 
        popularity_score: popularity_score
      }

      stream_hash_array << hash_form

      #stream_hash_array.sort_by! {|stream| stream[:popularity_score]}
    end

    #stream_hash_array = stream_hash_array.sort! {|stream_hash| stream_hash[:popularity_score]}

    #for now make a maximum of 5 recursions... per comment. But modify that later. Must be limited more intelligently than that later.
    return stream_hash_array
  end

  def update_stream_popularity_score

     net_likes = (self.streamable.likes - self.streamable.dislikes)
     net_likes = 1 if net_likes <= 0

      #calculate score of comment itself
      self.streamable.popularity_score = Math.log(net_likes)

        #Dylan's shitty code put into the middle of your function
        #write function that takes an array of replies.
        #in the function, loop through the replies.
        #if a reply has a reply, load the function again with that array of replies.
        #if it doesn't, log the popularity score
          #
        # def popularity_processor(streams)
        #  streams.each do |stream|
         #   streamable.popularity_score = streamable.likes - streamable.disklikes
            #put in exception for predictions.
          #  stream.replies.exist? #if there are replies, get the popularity score of those replies. this will also save and update the popularity of those sub-items.
           #   popularity_score += populiarty_processor(stream.replies) #loops the same function and sends in the stream array.
            #end

        #  streamable.save #updates the popularity score, including in the score the popularity scores of the sub items. Sub items will be updated also.
        #  return popularity_score
        #end

      #obtain array of replies to comments
      replies = self.streamable.replies

      unless replies.empty?
        replies.each do |reply|

          #Find all additional replies attached to 'reply', and add them to 'replies' array
          reply.replies.each {|reply| replies << reply}

          net_likes = (reply.likes - reply.dislikes)
          net_likes = 1 if net_likes <= 0
          self.streamable.popularity_score += Math.log(net_likes)
        end
      end

      #For prediction posts, addtional points are awarded for prediction score
      if self.streamable.class.name == "Prediction"
        #10 times prediction score is added to popularity score
        self.streamable.popularity_score += self.streamable.score
      end

      #Reduce popularity score 1 point per half day
      self.streamable.popularity_score -= (Time.zone.now - self.streamable.created_at)/(2*60*60*24)

      #Minimum popularity score obtainable is self popularity (likes minus dislikes)
      self.streamable.popularity_score = (self.streamable.likes - self.streamable.dislikes) if self.streamable.popularity_score < (self.streamable.likes - self.streamable.dislikes)

      #convert popularity score to integer
      self.streamable.popularity_score.round(0)

      self.streamable.save

      return self.streamable.popularity_score 
  end

end
