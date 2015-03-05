class Stock < ActiveRecord::Base

  require 'scraper'

  has_many :streams, as: :targetable, dependent: :destroy
  has_many :predictions
  
  validates :stock,         presence: true

  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}
  
  def followers
    Relationship.where(followed_id: self.id, followed_type: self.class.name)
  end
end

