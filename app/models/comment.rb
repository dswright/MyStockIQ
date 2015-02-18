class Comment < ActiveRecord::Base

	require 'popularity'
	include Popularity

	belongs_to :user
  	has_many :streams, as: :streamable, dependent: :destroy

	validates :content, presence: true, length: { maximum: 140}
	validates :popularity_score, presence: true, numericality: true
	default_scope -> { order(created_at: :desc) }


end
