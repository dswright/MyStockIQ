require 'test_helper'

class ReplyTest < ActiveSupport::TestCase

# For some reason the test won't recognize user id 
  def setup
  	@reply = Reply.new(content: "This is a reply", popularity_score: 0.0)
  end


  test "should be valid" do
  	assert @reply.valid?
  end

  test "content should be present" do
  	@reply.content = ""
  	assert_not @reply.valid?
  end

  test "content should be at most 1000 characters" do
  	@reply.content = "a" * 1001
  	assert_not @reply.valid?
  end

end
