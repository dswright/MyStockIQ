class Stock < ActiveRecord::Base

  require 'scraper'

  validates :stock,         presence: true

  validates :ticker_symbol, presence: true,
            uniqueness: {case_sensitive: false}

end

