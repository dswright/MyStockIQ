class Prediction < ActiveRecord::Base
  has_many :streams, as: :streamable
end
