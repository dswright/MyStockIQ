require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@user = users(:dylan)
		@comment = @user.comments.build(content: "This is the best thing I've ever seen in my life")
	end

	test "should be valid" do
		assert @comment.valid?
	end

	test "content should be present" do
		@comment.content = "     "
		assert_not @comment.valid?
	end

	test "content should be at most 5000 characters" do
		@comment.content = "a" * 5001
		assert_not @comment.valid?
	end

	test "user id should be present" do
		@comment.user_id = nil
		assert_not @comment.valid?
	end

	test "user id should be numerical" do
		@comment.user_id = "Not a number"
		assert_not @comment.valid?
	end
end
