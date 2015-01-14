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
      utc_date_number = CustomDate.utc_date_string_to_utc_date_number(prediction.end_date)
      graph_array << [utc_date_number, prediction.prediction_price]
    end
    graph_array.sort_by! {|price_point| price_point[0]}
    return graph_array
  end
end
