class Prediction < ActiveRecord::Base
  require 'customdate'
  require 'action_view'
  include ActionView::Helpers::DateHelper
  

  belongs_to :stock
  belongs_to :user
  has_many :streams, as: :streamable, dependent: :destroy
  has_many :predictionends, dependent: :destroy

  validates :prediction_end_price, presence: true, numericality: true
  validates :stock_id, presence: true, numericality: true
  validates :prediction_comment, length: {maximum: 140}
  default_scope -> { order(created_at: :desc) }


  def update_score
    #Calculates percentchange of prediction/start price and actual price/start price
    prediction_percentage = percent_change(self.prediction_end_price, self.start_price)
    actual_percentage = percent_change(prediction.stock.daily_stock_price, self.start_price)

    #Update prediction score
    self.score = calculate_score(prediction_percentage, actual_percentage)
    self.save
  end

  def final_update_score
    endprediction = Predictionend.find_by(prediction_id: self.id)

    prediction_percentage = percent_change(self.prediction_end_price, self.start_price)
    actual_percentage = percent_change(prediction.actual_end_price, self.start_price)

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

  def exceeds_end_time
    stock = Stock.find(self.stock_id)
    if stock.date >= self.prediction_end_time
      self.update(active:false)
      predictionend = self.predictionends.build(actual_end_time: stock.date, actual_end_price: stock.daily_stock_price, end_price_verified: false)
      predictionend.save

      stream_string = "Prediction:#{self.id},Stock:#{self.stock.id}"
      #build stream items for cancellation.
      stream_params_process(stream_string).each do |stream|
        predictionend.streams.build(stream).save
      end

    end
  end

  def exceeds_end_price

    stock = Stock.find(self.stock_id)

    prediction_percentage = percent_change(self.prediction_price, self.start_price)
    actual_percentage = percent_change(stock.daily_stock_price, self.start_price)

    #If actual price has surpassed prediction, end the prediction.
    if actual_percentage.abs > prediction_percentage.abs
      self.update(active:false)
      predictionend = self.predictionends.build(actual_end_time: stock.date, actual_end_price: self.stock.daily_stock_price, end_price_verified: false)
      predictionend.save

      stream_string = "Prediction:#{self.id},Stock:#{self.stock.id}"
      #build stream items for cancellation.
      stream_params_process(stream_string).each do |stream|
        predictionend.streams.build(stream).save
      end

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
