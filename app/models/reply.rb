class Reply < ActiveRecord::Base

	require 'popularity_past'
	include PopularityPast
	
	belongs_to :user
	belongs_to :repliable, polymorphic: :true
	has_many :streams, as: :streamable, dependent: :destroy
	has_many :likes, as: :likable
	has_one :popularity, as: :popularable, dependent: :destroy
	#FOR SOME REASON THE REPLY TEST DOESN"T RECOGNIZE USER ID AS A REPLY ATTRIBUTE
	validates :user_id, presence: true, numericality: true
	validates :content, presence: true, length: { maximum: 1000 }


	def replies
		replies = Reply.where(repliable_type: self.class.name, repliable_id: self.id)
	end
end
