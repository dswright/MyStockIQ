require 'test_helper'

class StreamTest < ActiveSupport::TestCase
 
 #Setup test post
  def setup
  	@user = users(:dylan)
  	@stream = @user.streams.build(user_id: @user.id, stream_type: "Prediction")
  end

  #Runs model validation tests on the stream
  test "should be valid" do
  	assert @stream.valid?
  end

  #Tests if user_id exists
  test "user id should be present" do
  	@stream.user_id = nil
  	assert_not @stream.valid?
  end
  

  #Tests to make sure most recent user post is listed first
  test "stream order should be most recent first" do
  	assert_equal Stream.first, streams(:most_recent)
  end
end
