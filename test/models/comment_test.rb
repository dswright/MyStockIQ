require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@comment = comments(:typical)
	end

	should validate_presence_of(:content)
	should validate_length_of(:content).is_at_most(5000)
	should validate_presence_of(:user_id)
	should validate_numericality_of(:user_id)
	should belong_to(:user)

	test "should be valid" do
		assert @comment.valid?
	end

end
