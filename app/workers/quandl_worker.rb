class QuandlWorker
  include Sidekiq::Worker

  require 'csv'
  require 'open-uri'
  require 'json'

  def perform(i)
    if i<=5
      stock_hash_array = []
      #set url = to the quandl json url.
      url = "http://www.quandl.com/api/v2/datasets.json?source_code=EOD&per_page=300&page=#{i}&auth_token=sVaP2d6ACjxmP-jM_6V-"
      #if the scrape is successful, set the data_string = to the json data if the scrape is successful
      data_string = open(url).read
      #parse out json file into an object
      data_set = JSON.parse(data_string)
      #return the object
      data_set_docs = data_set["docs"]
      data_set_docs.each do |row|
        stock_hash = Stock.new_stock(row)
        unless stock_hash.nil?
          stock_hash_array << stock_hash
        end
      end

      if stock_hash_array.count >= 1
        PEWorker.perform_async(stock_hash_array)
        IndustryWorker.perform_async(stock_hash_array)  
        HistoricalWorker.perform_async(stock_hash_array, 0, i)
      end
    end
  end
end