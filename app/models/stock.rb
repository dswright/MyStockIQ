class Stock < ActiveRecord::Base

  require 'scraper'

  has_many :streams, as: :targetable, dependent: :destroy
  has_many :predictions
  has_many :users, through: :predictions

  validates :stock,         presence: true
  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}

  
  def followers
    Relationship.where(followed_id: self.id, followed_type: self.class.name)
  end

  def top_analysts(top=100)
  	sorted_analysts = self.users.uniq.sort_by{|user| user.total_score(self)}
  	sorted_analysts.reverse.first(top)
  end
end

