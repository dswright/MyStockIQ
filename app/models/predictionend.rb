class Predictionend < ActiveRecord::Base
  belongs_to :prediction
  has_many :streams, as: :streamable, dependent: :destroy


end
