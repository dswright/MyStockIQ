require 'test_helper'

class StreamsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  #Create test stream post using the fixture :bonbon
  def setup
  	@stream = streams(:bonbon)
  end

  #When User not logged in: Redirect to login
  test "should redirect create when not logged in" do
  	assert_no_difference 'Stream.count' do
  		post :create, stream: { content: "Lorem Ipsum" }
  	end
  	assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
  	assert_no_difference 'Stream.count' do
  		delete :destroy, id: @stream
  	end
  	assert_redirected_to login_url
  end
end
