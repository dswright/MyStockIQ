class Comment < ActiveRecord::Base
  require 'popularity_past'
  include PopularityPast

	belongs_to :user
  	has_many :streams, as: :streamable, dependent: :destroy
  	has_one :popularity, as: :popularable, dependent: :destroy
  	has_many :likes, as: :likable
  	has_many :replies, as: :repliable

	validates :content, presence: true, length: { maximum: 140}
	default_scope -> { order(created_at: :desc) }


end
