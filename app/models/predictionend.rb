class Predictionend < ActiveRecord::Base
  require 'popularity'
  include PopularityPast

  belongs_to :prediction
  has_many :streams, as: :streamable, dependent: :destroy
  has_many :likes, as: :likable
  has_one :popularity, as: :popularable, dependent: :destroy

end
