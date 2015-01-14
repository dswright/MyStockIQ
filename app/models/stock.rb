class Stock < ActiveRecord::Base

  validates :stock,         presence: true

  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}
  
end

