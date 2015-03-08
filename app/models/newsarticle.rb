class Newsarticle < ActiveRecord::Base
  require 'popularity_past'
  include PopularityPast

  has_many :streams, as: :streamable, dependent: :destroy
  has_many :likes, as: :likable
  has_many :replies, as: :repliable
  has_one :popularity, as: :popularable, dependent: :destroy

end
