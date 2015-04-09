class Predictionend < ActiveRecord::Base
  require 'shared_methods'
  include SharedMethods

  belongs_to :prediction
  has_many :likes, as: :likable
  has_many :streams, as: :streamable, dependent: :destroy
  has_one :popularity, as: :popularable, dependent: :destroy
  has_one :tag, as: :tagable, dependent: :destroy
  has_many :replies, as: :repliable

  default_scope -> { order(created_at: :desc) }
end
