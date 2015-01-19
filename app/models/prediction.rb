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

  def update_prediction

    #Finds stock associated with prediction
    stock = Stock.find_by(id: self.stock_id)

    #Calculates percentchange of prediction/start price and actual price/start price
    prediction_percentage = percent_change(self.prediction_price, self.start_price)
    actual_percentage = percent_change(stock.daily_stock_price, self.start_price)

    #Update prediction score
    self.score = calculate_score(prediction_percentage, actual_percentage)

    #If actual price has surpassed prediction, cancel prediction
    self.active = false if actual_percentage.abs > prediction_percentage.abs

    self.save
  end

  def calculate_score(prediction_percentage, actual_percentage)
    #IF PREDICTION IS CORRECT: 
    if same_sign?(prediction_percentage, actual_percentage)

      #Award points based on actual percentage change
      score = actual_percentage.abs.round(2)

    #IF PREDICTION IS INCORRECT:
    else

      #Lose points based on actual percentage change
      score = -1*actual_percentage.abs.round(2)
    end
  end


  def percent_change(new_score, base_score)
    ((new_score - base_score)/base_score*100)
  end

  def same_sign?(num1, num2)
    if num1 >= 0 && num2 >= 0
      return true
    elsif num1 < 0 && num2 < 0
      return true
    else
      return false
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
