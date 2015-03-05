class Prediction < ActiveRecord::Base
  require 'popularity_past'
  include PopularityPast
  require 'customdate'
  require 'action_view'
  include ActionView::Helpers::DateHelper


  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable, dependent: :destroy
  has_many :likes, as: :likable
  has_one :predictionend, dependent: :destroy
  has_one :popularity, as: :popularable, dependent: :destroy

  validates :prediction_end_price, presence: true, numericality: true
  validates :stock_id, presence: true, numericality: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }



  def update_score
    #Calculates percentchange of prediction/start price and actual price/start price
    prediction_percentage = percent_change(self.prediction_end_price, self.start_price)
    actual_percentage = percent_change(self.stock.daily_stock_price, self.start_price)

    #Update prediction score
    self.score = calculate_score(prediction_percentage, actual_percentage)
    self.save
  end

  def final_update_score
    prediction_percentage = percent_change(self.prediction_end_price, self.start_price)
    actual_percentage = percent_change(self.predictionend.actual_end_price, self.start_price)

    #Update prediction score
    self.score = calculate_score(prediction_percentage, actual_percentage)
    self.save

  end


  def active_prediction_exists?
	 #Find current user prediction related to that stock
	 if Prediction.where(active: true, user_id: self.user.id, stock_id: self.stock.id).exists?
      true
    else 
      false
    end
  end


  def exceeds_end_price
    stock = Stock.find(self.stock_id)

    prediction_percentage = percent_change(self.prediction_end_price, self.start_price) #checks the amount and direction of the prediction.
    actual_percentage = percent_change(stock.daily_stock_price, self.start_price) #checks the amount and direction of the actual movement.

    #If actual price has surpassed prediction, end the prediction. It also has to be in the correct direction....
    if actual_percentage.abs > prediction_percentage.abs && same_sign?(prediction_percentage, actual_percentage)
      self.update(active:false)
      self.build_predictionend(actual_end_time: self.stock.date, actual_end_price: self.stock.daily_stock_price, end_price_verified: false).save
      predictionend.build_popularity(score:0).save
      predictionend.streams.build(target_type:"User", target_id: self.user.id).save
      predictionend.streams.build(target_type:"Stock", target_id: self.stock.id).save
    end
  end


  def exceeds_end_time
    if self.stock.date >= self.prediction_end_time
      self.update(active:false)
      self.build_predictionend(actual_end_time: self.prediction_end_time, actual_end_price: self.stock.daily_stock_price, end_price_verified: false).save
      predictionend.build_popularity(score:0).save
      predictionend.streams.build(target_type:"User", target_id: self.user.id).save
      predictionend.streams.build(target_type:"Stock", target_id: self.stock.id).save
    end
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
