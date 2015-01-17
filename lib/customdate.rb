class CustomDate
  
  #this takes a date in the form of - "2014-12-16 00:00:00 UTC" and converts to the utc time stamp like 13242342309203
  
  #returns a utc date time string like "Wed, 17 Dec 2014 19:00:00 EST -05:00"
  #this is the form that the array comes out of the database as.
  #inputting a string like "2015-01-01" will return Thu, 01 Jan 2015 00:00:00 EST -05:00
  def self.date_string_to_utc_date_string(date_string)
    utc_time_string = Time.zone.parse(date_string)
  end

  #takes input like Thu, 01 Jan 2015 00:00:00 EST -05:00 and returns 1420088400000
  def self.utc_date_string_to_utc_date_number(utc_date_string)
    utc_date_number = utc_date_string.to_time.to_i * 1000
  end

  #takes input like 1420088400000 and returns Thu, 01 Jan 2015 00:00:00 EST -05:00
  def self.utc_date_number_to_utc_date_string(utc_date_number)
    utc_time_string = Time.at(utc_date_number/1000).in_time_zone
  end

  #takes Thu, 01 Jan 2015 00:00:00 EST -05:00, and returns 2015-01-01
  def self.utc_date_string_to_date_string(utc_date_string)
    utc_date_string.to_s.in_time_zone.strftime("%Y-%m-%d")
  end

  #takes Thu, 01 Jan 2015 00:00:00 EST -05:00 and returns "19:00:00"
  def self.utc_date_string_to_date_string_hour(utc_date_string)
    utc_date_string.to_s.in_time_zone.strftime("%H:%M:%S")
  end

  def self.check_if_out_of_time(utc_date_number)

    #standard whole holidays are:
    #new years day, MLK day, Presidents day, Good Friday, Memorial Day, July 4th, Labor Day, Thanksgiving, Christmas
    holiday_array = [
      "2010-01-01", "2010-01-18", "2010-02-15", "2010-04-02", "2010-05-31", "2010-07-05", "2010-09-06", "2010-11-25", "2010-12-24",
      "2011-01-17", "2011-02-21", "2011-04-22", "2011-05-30", "2011-07-04", "2011-09-05", "2011-11-24", "2011-12-26",
      "2012-01-02", "2012-01-16", "2012-02-20", "2012-04-06", "2012-05-28", "2012-07-04", "2012-09-03", "2012-11-22", "2012-12-25",
      "2013-01-01", "2013-01-21", "2013-02-18", "2013-03-29", "2013-05-27", "2013-07-04", "2013-09-02", "2013-11-28", "2013-12-25",
      "2014-01-01", "2014-01-20", "2014-02-17", "2014-04-18", "2014-05-26", "2014-07-04", "2014-09-01", "2014-11-27", "2014-12-25",
      "2015-01-01", "2015-01-19", "2015-02-16", "2015-04-03", "2015-05-25", "2015-09-07", "2015-11-26", "2015-12-25",
      "2016-01-01", "2016-01-18", "2016-02-15", "2016-03-25", "2016-05-30", "2016-07-04", "2016-09-05", "2016-11-24", "2016-12-26",
      "2017-01-02", "2017-01-16", "2017-02-20", "2017-04-14", "2017-05-29", "2017-07-04", "2017-09-04", "2017-11-23", "2017-12-25",
      "2018-01-01", "2018-01-15", "2018-02-19", "2018-03-30", "2018-05-28", "2018-07-04", "2018-09-03", "2018-11-22", "2018-12-25"
    ]

    #Friday after thanksgiving and Christmas eve, when on a weekday, tend to be half days.
    half_day_array = [
      "2010-11-26",
      "2011-11-25",
      "2012-07-03", "2012-11-23", "2012-12-24",
      "2013-07-03", "2013-11-29", "2013-12-24",
      "2014-04-03", "2014-11-28", "2014-12-24",
      "2015-07-03", "2015-11-27", "2015-12-24", 
      "2016-11-25", "2016-12-23", 
      "2017-11-24", "2018-11-23", 
      "2018-12-24"
    ]

    utc_string_date = CustomDate.utc_date_number_to_utc_date_string(utc_date_number)
    holiday_format = CustomDate.utc_date_string_to_date_string(utc_string_date)
    hour_format = CustomDate.utc_date_string_to_date_string_hour(utc_string_date)

    if utc_string_date.wday == 6 || utc_string_date.wday == 0
      return true
    end

    if hour_format < "09:30:00" || hour_format > "16:00:00"
      return true
    end

    if holiday_array.include? holiday_format
      return true
    end

    if half_day_array.include? holiday_format
      if hour_format < "09:30:00" || hour_format > "13:00:00"
        return true
      end
    end

    return false

  end

  #last_utc_date_intraday, 60*5 (1 minute)*1000, 6.5*2.5*3600*1000.
  def self.valid_end_point(start_time, interval, length_of_time)
    i=0
    iterations_forward = length_of_time/interval
    while i<=iterations_forward do
      i += 1
      time_to_check = start_time + i*interval
      if CustomDate.check_if_out_of_time(time_to_check)
        iterations_forward += 1
      end
    end
    #sets the end time of the day to the final valid day at 4pm utc time.
    end_time = start_time + interval*iterations_forward
    return end_time
  end

  def self.valid_start_point(start_time, interval, length_of_time)
    i=0
    iterations_back = length_of_time/interval
    while i<=iterations_back do
      i += 1
      time_to_check = start_time - i*interval
      if CustomDate.check_if_out_of_time(time_to_check)
        iterations_back += 1
      end
    end
    #sets the end time of the day to the final valid day at 4pm utc time.
    end_time = start_time - interval*iterations_back
    return end_time
  end

  def self.closest_end_time(end_utc_time)
    #first, round to the nearest minute
    rounded_utc_string = CustomDate.utc_date_number_to_utc_date_string(end_utc_time).strftime("%Y-%m-%d %H:%M:00")
    
    #number has to be moved back 5 hours because the validation is in est.
    est_round_utc_number = CustomDate.utc_date_string_to_utc_date_number(rounded_utc_string) - 5*3600*1000

    #first check if the current time is valid
    #if this returns false, its in the time frame.
    unless CustomDate.check_if_out_of_time(est_round_utc_number)
      return CustomDate.utc_date_number_to_utc_date_string(est_round_utc_number + 5*3600*1000) #need to return the number to utc time for database insert.
    end

    #If its not in the current time frame, the prediction should always move to an EOD price.
    #If the prediction were to end in the morning of the next day, we need to subtract hours to get to the previous day.
    #so by default, we will subtract 9.5 hours, so that all times are gauranteed to fall into the previous day.
    back_dated_time = est_round_utc_number - 9.5*3600*1000

    i=0
    while i<= 10 #A valid day should be returned within 10 days.
      #if the first day is an invalid end day, then we need to iterate onto the next day.
      next_date = back_dated_time + i*24*3600*1000
      day_start_string = CustomDate.utc_date_number_to_utc_date_string(next_date).beginning_of_day
      day_end_number = CustomDate.utc_date_string_to_utc_date_number(day_start_string) + 16*3600*1000
      unless CustomDate.check_if_out_of_time(day_end_number)
        return CustomDate.utc_date_number_to_utc_date_string(day_end_number + 5*3600*1000)
      else
        #if the eod number is invalid, we should check the mid day number to ensure the day is not just a holiday.
        day_mid_number = CustomDate.utc_date_string_to_utc_date_number(day_start_string) + 13*3600*1000
        unless CustomDate.check_if_out_of_time(day_mid_number)
          return CustomDate.utc_date_number_to_utc_date_string(day_mid_number + 5*3600*1000)
        end
      end
      i+=1
    end
  end

  def self.closest_start_time(start_utc_time)
    rounded_utc_string = CustomDate.utc_date_number_to_utc_date_string(start_utc_time).strftime("%Y-%m-%d %H:%M:00")
    #number has to be moved back 5 hours because the validation is in est.
    est_round_utc_number = CustomDate.utc_date_string_to_utc_date_number(rounded_utc_string) - 5*3600*1000

    #first check if the current time is valid
    #if this returns false, its in the time frame.
    unless CustomDate.check_if_out_of_time(est_round_utc_number)
      return CustomDate.utc_date_number_to_utc_date_string(round_utc_number + 5*3600*1000) #need to return the number to utc time for database insert.
    end

    forward_dated_time = est_round_utc_number + 8*3600*1000 #move forward 8 hours to move any times in the afternoon to the next morning.

    #if the number is out of range, then move to the next day, incrementally.
    i=0
    while i<= 10 #A valid day should be returned within 10 days.
      #if the first day is an invalid end day, then we need to iterate onto the next day.
      next_date = forward_dated_time + i*24*3600*1000
      day_start_string = CustomDate.utc_date_number_to_utc_date_string(next_date).beginning_of_day
      day_start_number = CustomDate.utc_date_string_to_utc_date_number(day_start_string) + 9.5*3600*1000
      unless CustomDate.check_if_out_of_time(day_start_number)
        return CustomDate.utc_date_number_to_utc_date_string(day_start_number + 5*3600*1000)
      end
      i+=1
    end
  end


end
