class StocksWorker
  include Sidekiq::Worker

  def perform

    #Stock.fetch_new_stocks pulls the 28 pages of stock tickers from Quandl and checks for any new ticker symbols.
    #Saves new tickers to the db.
    #Returns list of inserted and failed inserts to the stock_array.
    stock_array = Stock.fetch_new_stocks
    #Takes the array of inserted stock objects and updates them with the correct stock industry.
    #Returns list of updated stock objects to the stock_array.
    stock_array[:inserted] = Stock.return_industry_array(@stock_array[:inserted])
    #additionally update the inserted values with the correct pe ratio.
    stock_array[:inserted] = Stock.return_pe(@stock_array[:inserted])
    #Sends an email with the array of failed and inserted stocks.
    StockMailer.new_stocks(@stock_array).deliver_now
  end
end