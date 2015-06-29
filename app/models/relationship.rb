class Relationship < ActiveRecord::Base


	belongs_to :followed, class_name: "User"

	validates :follower_id, presence: true
	validates :followed_id, presence: true
	validates :followed_type, presence: true

	

end

