require 'test_helper'

class PredictionTest < ActiveSupport::TestCase


	def setup
		@prediction = Prediction.find_by(user_id:1)
	end

	test "should be valid" do 
		assert @prediction.valid?
	end

  test "start price verify" do
    prediction = PredictionstartWorker.new.perform(@prediction.id)
    assert prediction.start_price_verified
  end

  test "prediction exceeds price" do
    prediction = Prediction.find_by(user_id:3)
    predictionends_before = Predictionend.all.count
    prediction.exceeds_end_price #this updates the prediction active to false, and creates a predictionend item.
    assert_not prediction.active
    assert Predictionend.all.count >= predictionends_before
  end

  test "prediction exceeds time" do
    prediction = Prediction.find_by(user_id:4)
    predictionends_before = Predictionend.all.count
    prediction.exceeds_end_time #this updates the prediction active to false, creates a prediction end item.
    assert_not prediction.active
    assert Predictionend.all.count >= predictionends_before
  end

  test "score update" do
    prediction = Prediction.find_by(user_id:5)
    prediction.update_score
    puts prediction.score
    assert prediction.score == 25
  end

  test "end price verify" do
    predictionend = Predictionend.find_by(prediction_id:6)
    predictionend = PredictionendWorker.new.perform(predictionend)
    assert predictionend.end_price_verified #should be true.
    assert predictionend.actual_end_price >= 100 #this should be greater than 100 as long as the actual LNKD price is greater than 100.
    assert predictionend.actual_end_time >= "2015-01-15 14:30:00" #the actual end time should be greater than this.
  end

  test "final_score_update" do
    prediction = Prediction.find_by(user_id:7)
    prediction.final_update_score
    assert prediction.score == 25
  end

end
