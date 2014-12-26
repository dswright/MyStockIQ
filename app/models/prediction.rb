class Prediction < ActiveRecord::Base
  belongs_to :user
  has_many :streams, as: :streamable
end
