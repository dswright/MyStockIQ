class Newsarticle < ActiveRecord::Base
  	require 'shared_methods'
  	include SharedMethods

  has_many :likes, as: :likable
  has_many :replies, as: :repliable
  has_many :streams, as: :streamable, dependent: :destroy
  has_one :popularity, as: :popularable, dependent: :destroy

  default_scope -> { order(created_at: :desc) }
end
