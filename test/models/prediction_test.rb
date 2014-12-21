require 'test_helper'

class PredictionTest < ActiveSupport::TestCase


	def setup
		@prediction = predictions(:sean)
	end

	test "should be valid" do 
		assert @prediction.valid?
	end
end
