require 'test_helper'

class StreamTest < ActiveSupport::TestCase
 
 #Setup test post
  def setup
    @user = users(:sean)
    @stock = stocks(:AAPL)
  	@comment = comments(:typical)

  	@stream = @comment.streams.build(targetable_type: "Stock", targetable_id: 1)
  end

  test "should be valid" do
  	assert @stream.valid?
  end

  test "streamable id should be present" do
  	@stream.streamable_id = nil
    assert_not @stream.valid?
  end

  test "streamable type should be present" do
  	@stream.streamable_type = nil
  	assert_not @stream.valid?
  end

  test "targetable id should be present" do
    @stream.targetable_id = nil
    assert_not @stream.valid?
  end

  test "targetable type should be present" do
    @stream.targetable_type = nil
    assert_not @stream.valid?
  end

  test "should belong to stock" do
    @stream = @stock.streams.build(streamable_type: "Newsarticle", targetable_id: 1)
    assert @stream.targetable_type == "Stock"
  end

  test "should belong to user" do
    @stream = @user.streams.build(streamable_type: "Predictionends", targetable_id: 1)
    assert @stream.targetable_type == "User"
  end


  #test "stream model order should be most recent first" do
  #	assert_equal Stream.first, streams(:most_recent)
  #end
end
