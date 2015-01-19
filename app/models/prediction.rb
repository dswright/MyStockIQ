class Prediction < ActiveRecord::Base
  require 'customdate'

  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable

  validates :prediction_price, presence: true, numericality: true
  validates :score, presence: true, numericality: true
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

#rake task executes a function. This function. It first checks for any predictions to verify. This could even go in the rake task.
#for the predictions that it does find to be unverified and past time... Execute the Google minute scraper for that stock.
#let the worker mark the prediction as verified.
  def predictions_to_verify
    time_now = Time.zone.now
    predictions = Prediction.where("start_time > ?", time_now)
    predictions.each do |prediction|
      GoogleminuteWorker.perform_async(prediction.stock.ticker_symbol, prediction.id)
    end  
  end

end
