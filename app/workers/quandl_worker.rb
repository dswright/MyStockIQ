class QuandlWorker
  include Sidekiq::Worker

  def perform(i)

    #set url = to the quandl json url.
    url = "http://www.quandl.com/api/v2/datasets.json?source_code=EOD&per_page=300&page=#{i}&auth_token=sVaP2d6ACjxmP-jM_6V-"
    #if the scrape is successful, set the data_string = to the json data if the scrape is successful
    data_string = open(url).read
    #parse out json file into an object
    data_set = JSON.parse(data_string)
    #return the object
    data_set_docs = data_set["docs"]
    data_set_docs.each do |row|
      Stock.new_stock(row)
    end
  end

end