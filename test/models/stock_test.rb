require 'test_helper'

class StockTest < ActiveSupport::TestCase

def setup
	@stock = stocks(:AAPL)
end

should validate_presence_of(:stock)
should validate_presence_of(:ticker_symbol)
should validate_uniqueness_of(:ticker_symbol)

should have_many(:streams)
should have_many(:predictions)
should have_many(:users)

test "should have active predictions" do
	assert Stock.with_predictions
end

test "should count active predictions" do
	@stock.active_predictions = 0
	@stock.count_active_predictions
	assert_equal @stock.active_predictions, @stock.predictions.active.count, "active predictions attribute does not match actual count"
end

test "should have popular_stocks" do
	assert Stock.popular_stocks(10).first, "popular stocks do not exist"
end

test "most popular stock should come up first" do
	popular_stocks = Stock.popular_stocks(10)	#obtain most popular stocks
	most_popular_score = popular_stocks.first.active_predictions			#first one should be most popular
	active_predictions = Array.new
	popular_stocks.each {|stock| active_predictions << stock.active_predictions} #aggregate active prediction count
	assert_equal most_popular_score, active_predictions.max, "most popular stock does not match expected score"
end

test "should have followers" do
	assert @stock.followers.first
end

	
end




