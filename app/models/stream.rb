class Stream < ActiveRecord::Base


  #declares a polymorphic association for the streams table. 
  belongs_to :streamable, polymorphic: true 
  belongs_to :targetable, polymorphic: true

  #uses Rails default_scope function to sort the posts such that the most recent one is first.
  default_scope -> {order(created_at: :desc)}

  scope :by_popularity_score, lambda { self.joins("join popularities on popularities.popularable_id = streams.streamable_id and popularities.popularable_type = streams.streamable_type").reorder("popularities.score DESC")}

  ######### STREAM MODEL VALIDATIONS ##########

  #Stream.valid? returns TRUE when:
  validates :streamable_id, presence: true, numericality: true
  validates :streamable_type, presence: true
  validates :targetable_id, presence: true, numericality: true
  validates :targetable_type, presence: true
  #Validates uniqueness of entire stream record
  validates :streamable_id, uniqueness: { scope: [:streamable_type, :targetable_id, :targetable_type]}

  def self.feed(user)
    following_ids = Array.new
    following_type = Array.new

    user.followings.each do |following|
      following_ids << following[0].id
      following_type << following[0].class.name
    end

    where(targetable_id: following_ids, targetable_type: following_type)
  end

  def update_stream_popularity_score
      #Update stream item's popularity score
      self.streamable.popularity.update_score

      #Find replies associated with stream item
      replies = self.streamable.replies

      unless replies.empty?
        replies.each do |reply|

        #Update reply's popularity score
        reply.popularity.update_score

        #Add reply's replies to the array of replies such that its popularity score gets updated later on in the loop
        #reply.replies.each {|reply| replies << reply}

      end

      return true
  end


  end


end
