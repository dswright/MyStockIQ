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

  def update_prediction(prediction)
    #Check the amount of time remaining on the prediction
    prediction.days_remaining = prediction.end_date - Time.now
    prediction.days_remaining = 0 if prediction.days_remaining < 0  

    #Set prediction to be inactive if there is no time remaining
    if prediction.days_remaining = 0
      prediction.active = 0
    end

    #Finds stock associated with prediction
    stock = Stock.find_by(id: prediction.stock_id)

    #Calculates today's projected prediction price
    todays_prediction = interpolate( prediction.created_at, prediction.start_price, prediction.end_date, prediction.prediction_price, Time.now )
    
    #Actual stock price for comparison
    todays_price = stock.daily_stock_price

    #Calculates percentchange of prediction/start price and actual price/start price
    prediction_percentage = percent_change(todays_prediction, prediction.start_price)
    actual_percentage = percent_change(todays_price, prediction.start_price)

    #Update prediction score
    prediction.score = calculate_score(prediction_percentage, actual_percentage)

    prediction.save
  end

  def calculate_score(prediction_percentage, actual_percentage)
    #IF PREDICTION IS CORRECT: 
    if same_sign?(prediction_percentage, actual_percentage)

      #points are awarded
      if prediction_percentage.abs <= actual_percentage.abs
        score = prediction_percentage.abs.round(2)
      else 
        score = (actual_percentage.abs - (prediction_percentage.abs - actual_percentage.abs)).round(2)
        score = 0 if score < 0
      end

    #IF PREDICTION IS INCORRECT:
    else
      #No points are awarded
      score = 0
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
