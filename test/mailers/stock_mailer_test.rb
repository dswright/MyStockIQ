require 'test_helper'

class StockMailerTest < ActionMailer::TestCase
  
  test "stock names" do
  	stock_array = {}
    # Send the email, then test that it got queued
    stock_array[:inserted] = [{ok: "something", ok1: "somethingagain"}, {ok2: "something", ok3: "something"}]
    stock_array[:failed] = [{ok: "something", ok1: "somethingagain"}, {ok2: "something", ok3: "something"}]
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
    	StockMailer.new_stocks(stock_array).deliver_now
    end
    #assert_not ActionMailer::Base.deliveries.empty?
 	end
end
