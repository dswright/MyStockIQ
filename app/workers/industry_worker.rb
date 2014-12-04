class IndustryWorker
  include Sidekiq::Worker

#this function recieves, the current stock array, and updates it with the stock industries too.
  def perform(stock_array)
    #fetch the array of tickers and related industries.
    stock_industry_array = Stock.fetch_industry_array
    #Loop through each line of the stocks to be inserted.

    stock_array.each do |stock|
      #check if the ticker to be inserted is listed in the industries array
      csv_stock_row = stock_industry_array.select {|a| a[:ticker_symbol]==stock["ticker_symbol"]}
      #if there is no match between the current ticker and the industries list, csv_stock_row will be empty.
      #if it is not empty, then update and save the new industry the table.
      unless csv_stock_row.empty?
        #find the stock to update
        stock_to_update = Stock.find_by(ticker_symbol:stock["ticker_symbol"])
        #set the stock_industry attribute of stock to the industry from the industries list.
        unless stock_to_update.nil?
          stock_to_update.stock_industry = csv_stock_row[0][:stock_industry]
          stock_to_update.save
        end
      end
    end
  end
end