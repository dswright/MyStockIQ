require 'test_helper'

class PopularityTest < ActiveSupport::TestCase

	def setup
		@comment = comments(:typical)
		@popularity = @comment.build_popularity(score: 0)
	end

	should validate_presence_of(:score)
	should validate_presence_of(:popularable_id)
	should validate_numericality_of(:popularable_id)
	should validate_presence_pf(:popularable_type)

	test "assert valid" do
		assert @popularity.valid?
	end

end
