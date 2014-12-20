class Stream < ActiveRecord::Base
  #sets association of stream model with user id
  belongs_to :user
  has_many :comments, dependent: :destroy

  #uses Rails default_scope function to sort the posts such that the most recent one is first.
  default_scope -> {order('created_at DESC')}


  ######### STREAM MODEL VALIDATIONS ##########

  #Stream.valid? returns TRUE when:

  validates :user_id, presence: true
  validates :stream_type, presence: true

end
