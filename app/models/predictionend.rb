class Predictionend < ActiveRecord::Base
  require 'popularity'
  include PopularityPast

  belongs_to :prediction
  has_many :streams, as: :streamable, dependent: :destroy

end
