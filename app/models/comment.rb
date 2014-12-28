class Comment < ActiveRecord::Base

	belongs_to :user
  	has_many :streams, as: :streamable

	validates :content, presence: true, length: { maximum: 140}
	default_scope -> { order(created_at: :desc) }
end
