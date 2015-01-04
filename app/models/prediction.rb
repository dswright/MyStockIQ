class Prediction < ActiveRecord::Base
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

end
