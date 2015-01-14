class Prediction < ActiveRecord::Base
  require 'customdate'

  belongs_to :stock
  belongs_to :user
  belongs_to :stock
  has_many :streams, as: :streamable

  validates :prediction_price, presence: true, numericality: true
  validates :active, presence: true, numericality: true
  validates :score, presence: true, numericality: true
  validates :end_date, presence: true
  validates :days_remaining, presence: true, numericality: true
  validates :stock_id, presence: true, numericality: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }


  def active_prediction_exists?

	 #Find current user prediction related to that stock
	 other_predictions = Prediction.where(active: 1, user_id: self.user.id, stock_id: self.stock.id)

    unless other_predictions == nil
      false
    else 
      true
    end

  end


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
