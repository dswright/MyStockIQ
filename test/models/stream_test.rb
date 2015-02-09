require 'test_helper'

class StreamTest < ActiveSupport::TestCase
 
 #Setup test post
  def setup
  	@user = users(:dylan)
  	@comment_stream = Streams.new(
                                            streamable_id: 1
                                            streamable_type: "Comment"
                                            target_type: "Stock", 
                                            target_id: 1),

  end

  test "should be valid" do
  	assert @comment_stream.valid?
  end

  test "parent id should be present" do
  	@comment_stream.streamable_id = nil
  	assert_not @comment_stream.valid?
  end

  test "parent type should be present" do
  	@comment_stream.streamable_type = nil
  	assert_not @comment_stream.valid?
  end

  
  test "stream model order should be most recent first" do
  	assert_equal Stream.first, streams(:most_recent)
  end
end
