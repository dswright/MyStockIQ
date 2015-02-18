class Stream < ActiveRecord::Base


  #declares a polymorphic association for the streams table. 
  belongs_to :streamable, polymorphic: true

  #uses Rails default_scope function to sort the posts such that the most recent one is first.
  default_scope -> {order('created_at DESC')}

  ######### STREAM MODEL VALIDATIONS ##########

  #Stream.valid? returns TRUE when:

  	#user_id exists
  	#validates :user_id, presence: true

  	#content exists and has a max length of 140 characters
  	#validates :content, presence: true, length: {maximum: 140}



  def self.stream_maker(streams, nest_count)

    stream_hashes = []
    streams.each do |stream|
      #begin making the hash immediately, making the parent item the first item in the array? Or just the sub comments?
      #the original array is just a list of stream items.. can that be sustained?
      #yes, it could still pass back a significantly different looking array item.
      #needs a recurrsive loop to go through this.
      #like [array_item, nest_count, sub_array, popularity_score],[array_item, nest_count, sub_array, popularity_score]
      sub_stream = []
      
      #the streamable_type and streamable_id will be the way to find the children of this stream item.

      sub_stream = Stream.where(target_type: stream.streamable_type, target_id: stream.streamable_id)
      unless sub_stream.empty?
        sub_stream = Stream.stream_maker(sub_stream, nest_count+1)
      end

      stream_hash = {
        stream: stream, 
        nest_count: nest_count, 
        sub_hash_array: sub_stream, 
        popularity_score: stream.streamable.popularity_score
      }

      stream_hashes << stream_hash

      
    end

    stream_hashes.sort_by! {|stream| stream[:popularity_score]}
    stream_hashes.reverse!
    #for now make a maximum of 5 recursions... per comment. But modify that later. Must be limited more intelligently than that later.
    return stream_hashes
  end

  def update_stream_popularity_scores
      #Update stream item's popularity score
      self.streamable.update_popularity_score

      #Find replies associated with stream item
      replies = self.streamable.replies

      unless replies.empty?
        replies.each do |reply|

          #Update reply's popularity score
          reply.update_popularity_score

          #Add reply's replies to the array of replies such that its popularity score gets updated later on in the loop
          reply.replies.each {|reply| replies << reply}

        end
    end
  end


end
