class Comment < ActiveRecord::Base

	belongs_to :stream
	validates :content, presence: true, length: { maximum: 140}
	default_scope -> { order(created_at: :desc) }
end
