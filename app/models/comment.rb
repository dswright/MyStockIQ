class Comment < ActiveRecord::Base

	require 'popularity'
	include PopularityPast

	belongs_to :user
  has_many :streams, as: :streamable, dependent: :destroy
  has_one :popularity, as: :popularable, dependent: :destroy


	validates :content, presence: true, length: { maximum: 140}
	default_scope -> { order(created_at: :desc) }


end
