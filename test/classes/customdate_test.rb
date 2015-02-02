require 'test_helper'
require 'customdate'

class CustomdateTest < ActiveSupport::TestCase

  test "string to utc time" do
    time_str = "2015-02-02"
    assert time_str.utc_time == "Mon, 02 Feb 2015 00:00:00 UTC 00:00"
  end

  test "utc time to utc time int" do 
    utc_time = "Mon, 02 Feb 2015 00:00:00 UTC 00:00:00".to_time.in_time_zone
    assert utc_time.utc_time_int == 1422835200
  end

  test "utc time int to utc time" do 
    utc_time_int = 1422835200
    assert utc_time_int.utc_time == "Mon, 02 Feb 2015 00:00:00 UTC 00:00:00"
  end

  test "utc time to utc time string" do 
    utc_time = "Mon, 02 Feb 2015 00:00:00 UTC 00:00:00".to_time.in_time_zone
    assert utc_time.utc_time_str == "2015-02-02"
  end

  test "utc date to utc time hour" do 
    utc_time = "Mon, 02 Feb 2015 00:00:00 UTC 00:00:00".to_time.in_time_zone
    assert utc_time.utc_time_hour == "00:00:00"
  end

  test "valid stock time?" do
    valid_times = ["2015-01-02 14:30:00", "2015-01-02 21:00:00", "2015-11-27 17:59:00"]
    invalid_times = ["2015-01-02 14:29:00", "2015-01-02 21:01:00", "2015-01-01 17:01:00", "2015-11-27 18:00:10", "2015-02-08 17:59:30"]
    
    valid_times.each do |time_str|
      assert time_str.utc_time.utc_time_int.valid_stock_time?
    end

    invalid_times.each do |time_str|
      assert_not time_str.utc_time.utc_time_int.valid_stock_time?
    end
  end

  test "closest end time" do
    #test that it returns current time if current time is valid, and that the rounding works.
    assert "2015-01-21 20:10:20".utc_time.utc_time_int.closest_end_time == "2015-01-21 20:10:00"

    #test that the day is moved to the end of the previous day for morning times.
    assert "2015-01-22 14:29:00".utc_time.utc_time_int.closest_end_time == "2015-01-21 21:00:00"

    #check that 1 minute past the end time goes to the correct end time.
    assert "2015-01-22 21:01:00".utc_time.utc_time_int.closest_end_time == "2015-01-22 21:00:00"

    #check that a sunday afternoon time gets moved to eod Friday
    assert "2015-01-18 16:00:00".utc_time.utc_time_int.closest_end_time == "2015-01-16 21:00:00"

    #check that a holiday morning time gets moved to eod for that holiday.
    assert "2015-07-03 20:00:00".utc_time.utc_time_int.closest_end_time == "2015-07-03 18:00:00"
  end

  test "closest start time" do
    #test that it returns current time if current time is valid, and that the rounding works.
    assert "2015-01-21 20:10:20".utc_time.utc_time_int.closest_start_time == "2015-01-21 20:10:00"

    #test that the day is moved to start of the day jsut before the day starts.
    assert "2015-01-22 14:29:00".utc_time.utc_time_int.closest_start_time == "2015-01-22 14:30:00"

    #check that 1 minute past the end time goes to the next day
    assert "2015-01-22 21:01:00".utc_time.utc_time_int.closest_start_time == "2015-01-23 14:30:00"

    #check that a friday afternoon time gets moved to start of day tuesday, monday is a holiday.
    assert "2015-01-16 21:05:00".utc_time.utc_time_int.closest_start_time == "2015-01-20 14:30:00"
  end

end