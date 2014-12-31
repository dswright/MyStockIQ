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


   def self.stream_maker(stream, indent_count)
    {
      stream_array = []
      stream.each do |stream_item|
        #begin making the array immediately..

        #pull from the stream where the target item is the id of the current stream item.
        


      #each comment will be an array?


      #for now make a maximum of 5 recursions... per comment. But modify that laster. Must be limited more intelligently than that later.
      return stream_array

    }

end
