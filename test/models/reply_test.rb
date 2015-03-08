require 'test_helper'

class ReplyTest < ActiveSupport::TestCase

# For some reason the test won't recognize user id 
  def setup
    @user = user[:dylan]
  	@reply = @user.reply.build(repliable_type: "Comment", repliable_id: 1, content: "This is a reply")
  end


  test "should be valid" do
  	assert @reply.valid?
  end

  test "user id should be present" do
    @reply.user_id = nil
    assert_not @reply.valid?
  end

  test "repliable id should be present" do
    @reply.repliable_id = nil
    assert_not @reply.valid?
  end

  test "repliable type should be present" do
    @reply.repliable_type = nil
    assert_not @reply.valid?
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
