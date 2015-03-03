class Newsarticle < ActiveRecord::Base
  has_many :streams, as: :streamable
  has_one :popularity, as: :popularable, dependent: :destroy

  require 'popularity'
  include PopularityPast

end
