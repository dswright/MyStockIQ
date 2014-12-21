require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@user = users(:dylan)
		@post = Stream.new(user_id: @user.id, stock_id: 1, stream_type: "comment")
		@comment = Comment.new(stream_id: @post.id, content: "Loren Ipsum")
	end

	test "should be valid" do
		assert @comment.valid?
	end

	test "content should be present" do
		@comment.content = "     "
		assert_not @comment.valid?
	end

	test "content should be at most 140 characters" do
		@comment.content = "a" * 141
		assert_not @comment.valid?
	end
end
