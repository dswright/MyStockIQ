class Reply < ActiveRecord::Base

	require 'popularity_past'
	include PopularityPast
	
	belongs_to :user
	belongs_to :repliable, polymorphic: :true
	has_many :streams, as: :streamable, dependent: :destroy
	has_many :likes, as: :likable
	has_one :popularity, as: :popularable, dependent: :destroy


	validates :user_id, presence: true, numericality: true
	validates :repliable_id, presence: true, numericality: true
	validates :repliable_type, presence: true
	validates :content, presence: true, length: { maximum: 5000 }


	def replies
		replies = Reply.where(repliable_type: self.class.name, repliable_id: self.id)
	end
end
