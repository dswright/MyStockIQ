class String
  def utc_time
    Time.zone.parse(self)
  end
end

class Time
  def utc_time_int
    self.to_time.to_i
  end
  def utc_time_str
    self.to_s.in_time_zone.strftime("%Y-%m-%d")
  end
  def utc_time_hour
    self.to_s.in_time_zone.strftime("%H:%M:%S")
  end
  def utc_time_full
    self.to_s.in_time_zone.strftime("%Y-%m-%d %H:%M:%S")
  end
end

class Integer
  def utc_time
    Time.at(self).in_time_zone
  end
  def utc_time_int
    tz = ActiveSupport::TimeZone.new('America/New_York')
    offset = tz.parse(self.utc_time.utc_time_full).utc_offset()
    self/1000 - offset  #offset is negative, so this will add the offset amount.
  end
  def graph_time_int
    tz = ActiveSupport::TimeZone.new('America/New_York')
    offset = tz.parse(self.utc_time.utc_time_full).utc_offset()
    (self+offset) * 1000  #offset is negative, so this will subtract the offset amount.
  end

  #expects to take an int in utc time.
  def valid_stock_time?

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

    utc_time = self.utc_time
    holiday_format = utc_time.utc_time_str
    hour_format = utc_time.utc_time_hour

    if utc_time.wday == 6 || utc_time.wday == 0
      return false
    end

    if hour_format < "14:30:00" || hour_format > "21:00:00" #validation times are in utc time, 5 hours ahead of est.
      return false
    end

    if holiday_array.include? holiday_format
      return false
    end

    if half_day_array.include? holiday_format
      if hour_format < "14:30:00" || hour_format > "18:00:00" #validation times are in utc time, 5 hours ahead of est.
        return false
      end
    end

    return true
  end

  #these functions are probably best for being graph specific... they're pretty wierd.. no other situation for needing these.

  #this function returns a valid end date in the future. It looks a length_of_time ahead, iterating through every point in between
  #to check the validity of each point. If the point is invalid, the length of time looking forward is extended.
  #utc_time_int: the time to start looking.
  #interval: amount of time in seconds between checks for a valid date.
  #length_of_time: the amount of time ahead, in valid stock market time, of the start time to begin looking for valid dates.


  #returns the closest end time. Used for a variety of things. probably best as a function of ints.
  #expects to receieve an int, but returns a date string..
  
  #THIS FUNCTION IS NOW OUT OF USE.
  def closest_end_time
    #increase the time by 1 minute, since these formulas round down.
    int_time = self + 60
    #first, round to the nearest minute
    rounded_utc_time_int = int_time.utc_time.strftime("%Y-%m-%d %H:%M:00").utc_time.utc_time_int

    #first check if the current time is valid
    #if this returns false, its in the time frame.
    if rounded_utc_time_int.valid_stock_time?
      return rounded_utc_time_int.utc_time #return the datetime format for insert into db.
    end

    #If its not in the current time frame, the prediction should always move to an EOD price.
    #If the prediction were to end in the morning of the next day, we need to subtract hours to get to the previous day.
    #so by default, we will subtract 14.5 hours, so that all times are gauranteed to fall into the previous day.
    back_dated_utc_time_int = rounded_utc_time_int - 14.5*3600

    i=0
    while i<= 10 #A valid day should be returned within 10 days.
      #if the first day is an invalid end day, then we need to iterate onto the next day.
      next_utc_time_int = (back_dated_utc_time_int - i*24*3600).to_i
      day_start_utc_time = next_utc_time_int.utc_time.beginning_of_day
      day_end_utc_time_int = day_start_utc_time.utc_time_int + 21*3600
      if day_end_utc_time_int.valid_stock_time?
        return day_end_utc_time_int.utc_time
      else
        #if the eod number is invalid, we should check the mid day number to ensure the day is not just a holiday.
        day_mid_utc_time_int = day_start_utc_time.utc_time_int + 18*3600
        if day_mid_utc_time_int.valid_stock_time?
          return day_mid_utc_time_int.utc_time
        end
      end
      i+=1
    end
  end

  def closest_start_time
    #increase the time by 1 minute, since these formulas round down.
    int_time = self + 60
    rounded_utc_time_int = int_time.utc_time.strftime("%Y-%m-%d %H:%M:00").utc_time.utc_time_int

    #first check if the current time is valid
    #if this returns false, its in the time frame.
    if rounded_utc_time_int.valid_stock_time?
      return rounded_utc_time_int.utc_time
    end

    forward_dated_time = rounded_utc_time_int + 3*3600 #move forward 3 hours to move any times in the afternoon to the next morning.

    #if the number is out of range, then move to the next day, incrementally.
    i=0
    while i<= 10 #A valid day should be returned within 10 days.
      #if the first day is an invalid end day, then we need to iterate onto the next day.
      next_utc_time_int = forward_dated_time + i*24*3600
      day_start_utc_time = next_utc_time_int.utc_time.beginning_of_day
      morning_utc_time_int = (day_start_utc_time.utc_time_int + 14.5*3600).to_i
      if morning_utc_time_int.valid_stock_time?
        return morning_utc_time_int.utc_time
      end
      i+=1
    end
  end
end