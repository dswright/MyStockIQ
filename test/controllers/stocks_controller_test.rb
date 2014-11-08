require 'test_helper'

class StocksControllerTest < ActionController::TestCase
  test "get create method of stocks controller" do
    #don't test the create function regularly, the scraper slows down the testing suite.
    #get :create
    #assert_response :success
  end

  test "should get stock page" do
  	get :show
  	assert_response :success
  end
  
end
