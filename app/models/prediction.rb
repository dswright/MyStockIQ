class Prediction < ActiveRecord::Base
  require 'shared_methods'
  include SharedMethods
  require 'customdate'
  require 'action_view'
  include ActionView::Helpers::DateHelper


  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable, dependent: :destroy
  has_many :likes, as: :likable
  has_many :replies, as: :repliable
  has_one :predictionend, dependent: :destroy
  has_one :popularity, as: :popularable, dependent: :destroy
  has_one :tag, as: :tagable, dependent: :destroy
  
  validates :prediction_end_price, numericality: {message: "Make sure to include a prediction price!" }
  validates :prediction_end_time, presence: true
  validates :score, numericality: true
  #validates :start_price_verified, presence: true
  validates :start_time, presence: true
  validates :graph_start_time, presence: true
  validates :graph_end_time, presence: true
  validates :stock_id, numericality: true


  default_scope -> { order(created_at: :desc) }

  attr_accessor :invalid

  def invalid_end_price
    errors[:prediction_end_price].clear
    errors[:base] << "Make sure to include a prediction price!" 
    self.invalid = true
  end


  def invalid_end_time
    errors[:prediction_end_time].clear
    errors[:graph_end_time].clear
    errors[:base] << "Your prediction starts and ends at the same time. Please increase your prediction end time."
    self.invalid = true
  end

  def invalid_date
    errors[:prediction_end_time].clear
    errors[:graph_end_time].clear
    errors[:base] << "Please select an end date"
    self.invalid = true
  end

  def invalid_time
    errors[:prediction_end_time].clear
    errors[:graph_end_time].clear
    errors[:base] << "Please select an end time"
    self.invalid = true
  end

  def already_exists
    errors[:base] << "You already have an active prediction on #{self.stock.ticker_symbol}"
    self.invalid = true
  end
  

  def days_remaining
    days_remaining = (self.prediction_end_time - Time.now)/(60*60*24).round(0)
    
    if days_remaining < 0
      days_remaining = 0
    end

    return days_remaining
  end


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


  def exceeds_end_price
    stock = Stock.find(self.stock_id)

    intraday_prices = Intradayprice.where(ticker_symbol:stock.ticker_symbol).where("date > ?",self.start_time).reorder("date desc").limit(80).reverse #looks 1 day backwards at the intradayprices

    intraday_prices.each do |price|      

      prediction_percentage = percent_change(self.prediction_end_price, self.start_price) #checks the amount and direction of the prediction.
      actual_percentage = percent_change(price.close_price, self.start_price) #checks the amount and direction of the actual movement.

      #If actual price has surpassed prediction, end the prediction. It also has to be in the correct direction....
      if actual_percentage.abs > prediction_percentage.abs && same_sign?(prediction_percentage, actual_percentage)
        self.update(active:false)
        self.build_predictionend(actual_end_time: price.date, actual_end_price: price.close_price, end_price_verified: false, graph_end_time: price.date.graph_time).save
        predictionend.build_popularity(score:0).save
        predictionend.streams.build(targetable_type:"User", targetable_id: self.user.id).save
        predictionend.streams.build(targetable_type:"Stock", targetable_id: self.stock.id).save
        break
      end
    end
  end

  def exceeds_end_time
    if self.stock.date >= self.prediction_end_time
      self.update(active:false)
      self.build_predictionend(actual_end_time: self.prediction_end_time, actual_end_price: self.stock.daily_stock_price, end_price_verified: false, graph_end_time: self.prediction_end_time.graph_time).save
      predictionend.build_popularity(score:0).save
      predictionend.streams.build(targetable_type:"User", targetable_id: self.user.id).save
      predictionend.streams.build(targetable_type:"Stock", targetable_id: self.stock.id).save
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
