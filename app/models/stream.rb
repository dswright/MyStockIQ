class Stream < ActiveRecord::Base
  #declares a polymorphic association for the streams table. 
  belongs_to :streamable, polymorphic: true, dependent: :destroy

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

    end

    #stream_hash_array = stream_hash_array.sort! {|stream_hash| stream_hash[:popularity_score]}

    #for now make a maximum of 5 recursions... per comment. But modify that later. Must be limited more intelligently than that later.
    return stream_hash_array
  end

end
