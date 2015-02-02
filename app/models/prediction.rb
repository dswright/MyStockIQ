class Prediction < ActiveRecord::Base
  require 'customdate'
  require 'popularity'
  include Popularity

  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable

  validates :prediction_end_price, presence: true, numericality: true
  validates :score, presence: true, numericality: true
  validates :stock_id, presence: true, numericality: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }


  def active_prediction_exists?

	 #Find current user prediction related to that stock
	 other_predictions = Prediction.where(active: true, user_id: self.user.id, stock_id: self.stock.id)

    unless other_predictions == nil
      false
    else 
      true
    end
  end

  def price_exceeds_prediction

    stock = Stock.find(self.stock_id)

    prediction_percentage = percent_change(self.prediction_price, self.start_price)
    actual_percentage = percent_change(stock.daily_stock_price, self.start_price)

    #If actual price has surpassed prediction, move the actual end time of the current prediction to the current time.
    if actual_percentage.abs > prediction_percentage.abs
      self.update(active:false)
      self.actual_end_time = stock.date
    end
    

  end


  def update_prediction

    #Finds stock associated with prediction
    stock = Stock.find(self.stock_id)

    #Calculates percentchange of prediction/start price and actual price/start price
    prediction_percentage = percent_change(self.prediction_price, self.start_price)
    actual_percentage = percent_change(stock.daily_stock_price, self.start_price)

    #Update prediction score
    self.score = calculate_score(prediction_percentage, actual_percentage)
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

end
