class Comment < ActiveRecord::Base
  	require 'shared_methods'
  	include SharedMethods

	belongs_to :user
	has_one :popularity, as: :popularable, dependent: :destroy
  	has_many :streams, as: :streamable, dependent: :destroy
	has_many :likes, as: :likable
	has_many :replies, as: :repliable
	has_one :tag, as: :tagable, dependent: :destroy

	validates :content, presence: true, length: { maximum: 5000}
	validates :user_id, presence: true, numericality: true
	default_scope -> { order(created_at: :desc) }

	scope :by_user, lambda {|user| where(user_id: user.id)}

	def invalid_content
		errors[:content].clear
		errors[:base] << "Oops! You have to say something to post a comment!"
	end

end
