require 'test_helper'

class PopularityTest < ActiveSupport::TestCase

	def setup
		@comment = comments(:typical)
		@popularity = @comment.build_popularity(score: 0)
	end

	test "assert valid" do
		assert @popularity.valid?
	end

	test "score should be present" do
		@popularity.score = nil
		assert_not @popularity.valid?
	end

	test "popularable id should be present" do
		@popularity.popularable_id = nil
		assert_not @popularity.valid?
	end

	test "popularable id should be numerical" do
		@popularity.popularable_id = "Not a number"
		assert_not @popularity.valid?
	end

	test "popularable type should be present" do
		@popularity.popularable_type = nil
		assert_not @popularity.valid?
	end

end
