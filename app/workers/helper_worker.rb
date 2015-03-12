#this is a file to write random functions for one time modifications.

class HelperWorker
  include Sidekiq::Worker
  require 'scraper'

  def perform(ticker_symbol)
    stockprices = Stockprice.where(ticker_symbol:ticker_symbol).reorder("date Desc").limit(1501)
    case_lines = []
    stockprices[0..-2].each_with_index do |stockprice, index|
      previous_price = stockprices[index+1].close_price
      if previous_price == 0
        daily_percent_change = 0
      else
        daily_percent_change = ((stockprice.close_price/previous_price -1)*100).round(2)
      end
      case_lines << "WHEN date = '#{stockprice.date}' THEN #{daily_percent_change}"
    end
    unless case_lines.empty?
      sql = "update stockprices
              SET daily_percent_change = CASE
                #{case_lines.join("\n")}
              END
            WHERE ticker_symbol = '#{ticker_symbol}';" #this is the sql shell that runs. Its contents are based on its 2 arrays.
      ActiveRecord::Base.connection.execute(sql) #this executes the raw sql.
    end
  end
end





