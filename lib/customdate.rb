class String
  #converts time strings like "2010-06-03" to Times like Thu, 03 Jun 2010 00:00:00 UTC +00:00
  def utc_time
    Time.zone.parse(self)
  end

  #converts time strings like "2010-06-03" to graphtime like 1275523200000
  def graph_time 
    self.utc_time.to_time.to_i*1000
  end

end

class Time

  #returns the DST offset amount in graphtime milliseconds.
  #takes a timestamp and returns either 0 or 3600*1000 (1 hour).
  #returns 1 hour when the time is 20:00 utc, and 0 when the hour is 21:00 utc.
  def offset_num
    tz = ActiveSupport::TimeZone.new('America/New_York') #set the time zone to EST.
    num = (tz.parse(self.to_s).utc_offset().to_i + 18000)*1000 #the utc_offset returns either -18000 or -14400, which results in 1 hour or 0 being returned.
  end

  #converts Time stamps like "Thu, 03 Jun 2010 00:00:00 UTC +00:00" to graphtime like 1275523200000
  def graph_time
    self.to_time.to_i*1000
  end
end

class Integer
  def utc_time
    Time.at(self/1000).in_time_zone
  end

  #expects to take a graphtime int.
  def valid_stock_time?

    #takes a timestamp and returns a simple string with the year, month, and day.
    def utc_time_str(graph_time)
      graph_time.to_s.in_time_zone.strftime("%Y-%m-%d")
    end
  
    #takes a timestamp and returns a simple string with the hour, minute, and second.
    def utc_time_hour(graph_time)
      graph_time.to_s.in_time_zone.strftime("%H:%M:%S")
    end

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
      "2018-01-01", "2018-01-15", "2018-02-19", "2018-03-30", "2018-05-28", "2018-07-04", "2018-09-03", "2018-11-22", "2018-12-25",
      "2019-01-01", "2019-01-21", "2019-02-18", "2019-04-19", "2019-05-27", "2019-07-04", "2019-09-02", "2019-11-28", "2019-12-25",
      "2020-01-01", "2020-01-20", "2020-02-17", "2020-04-10", "2020-05-25", "2020-07-03", "2020-09-07", "2020-11-26", "2020-12-25"
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
      "2018-12-24",
      "2019-07-03", "2019-11-29", "2019-12-24",
      "2020-07-03", "2020-11-25", "2020-12-24"
    ]

    offset = self.utc_time.offset_num

    adjusted_graph_time = self + offset
    utc_time = adjusted_graph_time.utc_time #adjusts the time to handle DST.
    
    holiday_format = utc_time_str(utc_time)
    hour_format = utc_time_hour(utc_time)

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

  #this function returns a valid end date in the future. It looks a length_of_time ahead, iterating through every point in between
  #to check the validity of each point. If the point is invalid, the length of time looking forward is extended.

  #This is expecting a graphtime integer to process.
  #it returns a timestamp.
  def closest_start_time
    #increase the time by 1 minute, since these formulas round down.
    int_time = self + (60*1000)
    rounded_graph_time = int_time.utc_time.strftime("%Y-%m-%d %H:%M:00").graph_time #round to start of day graph time.

    #first check if the current time is valid
    #if this returns false, its in the time frame.
    if rounded_graph_time.valid_stock_time?
      return rounded_graph_time.utc_time
    end

    #this needs to be 4 hours during DST.
    forward_graph_time = rounded_graph_time + (3*3600*1000) + rounded_graph_time.utc_time.offset_num #move forward 3 or 4 hours to move any times in the afternoon to the next morning.

    #if the number is out of range, then move to the next day, incrementally.
    i=0
    while i<= 10 #A valid day should be returned within 10 days.
      #if the first day is an invalid end day, then we need to iterate onto the next day.
      next_utc_time_int = forward_graph_time + i*24*3600*1000
      day_start_utc_time = next_utc_time_int.utc_time.beginning_of_day
      morning_graph_time = day_start_utc_time.graph_time + 13.5*3600*1000 + day_start_utc_time.offset_num
      if morning_graph_time.to_i.valid_stock_time?
        return morning_graph_time.to_i.utc_time
      end
      i+=1
    end
  end
end



def day_filler
  start_time = "2015-06-02".utc_time.graph_time + 16*3600*1000

  i = 0
  while i < 2040
    test_time = start_time+i*24*3600*1000
    day_start = test_time - 16*3600*1000
    day_end = day_start+21*3600*1000 - day_start.utc_time.offset_num 
    if (test_time).valid_stock_time?
      day = day_end.utc_time
      g_t = day_end
      fd = Futureday.new(day:day, graph_time:g_t)
      fd.save
    end
  end
end

def day_filler
  start_time = "2015-06-02".utc_time.graph_time + 16*3600*1000
  inserts = []
  i = 1
  while i <= 2038
    test_time = start_time+i*24*3600*1000
    day_start = test_time - 16*3600*1000
    day_end = day_start+21*3600*1000 - day_start.utc_time.offset_num 
    if (test_time).valid_stock_time?
      day = day_end.utc_time
      t = Time.now.utc
      inserts.push "(#{i}, '#{t}', '#{t}', '#{day}', #{day_end})"
    end
    i += 1
  end
  sql = "INSERT INTO futuredays (id, created_at, updated_at, date, graph_time) VALUES #{inserts.join(", ")}"
  ActiveRecord::Base.connection.execute sql
end

def time_filler
  start_time = "2015-06-03 00:00:00".utc_time.graph_time
  inserts = []
  i = 1
  while i <= 586944
    t = start_time + i*60*5*1000
    if t.valid_stock_time?
      date = t.utc_time
      now = Time.now.utc
      inserts.push "(#{i}, '#{now}', '#{now}', '#{date}', #{t})"
    end
    i += 1
  end
  sql = "INSERT INTO futuretimes (id, created_at, updated_at, time, graph_time) VALUES #{inserts.join(", ")}"
  ActiveRecord::Base.connection.execute sql
end
