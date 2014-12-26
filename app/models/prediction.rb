class Prediction < ActiveRecord::Base
  belongs_to :user
  has_many :streams, as: :streamable

  validates :prediction_price, presence: true, numericality: true
  validates :score, presence: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }
end
