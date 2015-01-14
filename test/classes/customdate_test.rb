require 'test_helper'
require 'customdate'

class CustomdateTest < ActiveSupport::TestCase

  test "date_string_to_utc_date_string" do
    date_string = "2015-02-02"
    utc_date_string = CustomDate.date_string_to_utc_date_string(date_string)
    assert utc_date_string == "Mon, 02 Feb 2015 00:00:00 EST -05:00"
  end

  test "utc_date_string_to_utc_date_number" do 
    utc_date_string = "Mon, 02 Feb 2015 00:00:00 EST -05:00"
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert utc_date_number == 1422853200000
  end

  test "utc_date_number_to_utc_date_string" do 
    utc_date_number = 1422853200000
    utc_date_string = CustomDate.utc_date_number_to_utc_date_string(utc_date_number)
    assert utc_date_string == "Mon, 02 Feb 2015 00:00:00 EST -05:00"
  end

  test "utc_date_string_to_date_string" do 
    utc_date_string = "Mon, 02 Feb 2015 00:00:00 EST -05:00"
    date_string = CustomDate.utc_date_string_to_date_string(utc_date_string)
    assert date_string == "2015-02-02"
  end

  test "utc_date_string_to_date_string_hour" do 
    utc_date_string = "Mon, 02 Feb 2015 00:00:00 EST -05:00"
    date_string_hour = CustomDate.utc_date_string_to_date_string_hour(utc_date_string)
    assert date_string_hour == "00:00:00"
  end

  test "check if out of time" do
    #Friday, January 2nd, 9 30 in the morning, should return false
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-02 09:30:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert_not CustomDate.check_if_out_of_time(utc_date_number)

    #Friday, January 2nd, 9 25 in the morning, should return true
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-02 09:29:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert CustomDate.check_if_out_of_time(utc_date_number)

    #Friday, January 2nd, 16:00 in the afternoon, should return false
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-02 16:00:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert_not CustomDate.check_if_out_of_time(utc_date_number)

    #Friday, January 2nd, 16:00 in the afternoon, should return true
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-02 16:01:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert CustomDate.check_if_out_of_time(utc_date_number)

    #Thursday, January 1st, a holiday, should return true
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-01-01 12:01:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert CustomDate.check_if_out_of_time(utc_date_number)

    #Friday, November 27th, a halfday, should return true past 1 pm
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-11-27 13:00:10")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)
    assert CustomDate.check_if_out_of_time(utc_date_number)

    #Friday, Novembert 27th, a halfday, should return false from 9 30 to 1 pm
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-11-27 12:59:00")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)    
    assert_not CustomDate.check_if_out_of_time(utc_date_number)

    #Sunday, Feb 28th 2015, should return true due to weekend
    utc_date_string = CustomDate.date_string_to_utc_date_string("2015-02-08 12:59:30")
    utc_date_number = CustomDate.utc_date_string_to_utc_date_number(utc_date_string)    
    assert CustomDate.check_if_out_of_time(utc_date_number)
  end
end