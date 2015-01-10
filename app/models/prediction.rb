class Prediction < ActiveRecord::Base
  require 'customdate'

  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable

  validates :prediction_price, presence: true, numericality: true
  validates :active, presence: true, numericality: true
  validates :score, presence: true, numericality: true
  validates :end_date, presence: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }

  def self.graph_prediction_points(stock_id)  
    graph_array = []
    prediction_array = Prediction.where(stock_id:stock_id)
    prediction_array.each do |prediction|
      utc_time = CustomDate.utc_time(prediction.date.to_s)
      graph_array << [utc_time, prediction.prediction_price]
    end
    return graph_array
  end
end
