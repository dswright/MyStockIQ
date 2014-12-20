require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@stream = streams(:bonbon)
		@comment = Comment.new(content: "Loren ipsum", stream_id: @stream.id)
	end


	test "should be valid" do
		assert @comment.valid?
	end

	test "stream id should be present" do
		@comment.stream_id = nil
		assert_not @comment.valid?
	end

	test "content should be present" do
  		@comment.content = "  "
  		assert_not @comment.valid?
  end

  test "content should be at most 140 characters" do
  	@comment.content = "a" * 141
  	assert_not @comment.valid?
  end

  test "order should be most recent first" do
  	assert_equal Comment.first, comments(:most_recent)
  end
end
