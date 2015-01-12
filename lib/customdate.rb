class CustomDate
  
  #this takes a date in the form of - "2014-12-16 00:00:00 UTC" and converts to the utc time stamp like 13242342309203
  def self.utc_time(date_string)
    utc_time = Time.parse(date_string).getutc.to_time.to_i * 1000
  end

  def self.utc_time_to_string(utc_time)
    date_string = DateTime.strptime((utc_time/1000).to_s, '%s')
  end

  def self.check_if_out_of_time(utc_time)

    #standard whole holidays are:
    #new years day, MLK day, Presidents day, Good Friday, Memorial Day, July 4th, Labor Day, Thanksgiving, Christmas
    holiday_array = ["2015-01-01", "2015-01-19", "2015-02-16", "2015-04-03", "2015-05-25", "2015-07-03", "2015-07-04", "2015-09-07", "2015-11-26", "2015-12-25",
    "2016-01-01", "2016-01-18", "2016-02-15-", "2016-03-25", "2016-05-30", "2016-07-04", "2016-09-05", "2016-11-24", "2016-12-26",
    "2017-01-02", "2017-01-16", "2017-02-20", "2017-04-14", "2017-05-29", "2017-07-04", "2017-09-04", "2017-11-23", "2017-12-25",
    "2018-01-01", "2018-01-15", "2018-02-19", "2018-03-30", "2018-05-28", "2018-07-04", "2018-09-03", "2018-11-22", "2018-12-25"]

    #Friday after thanksgiving and Christmas eve, when on a weekday, tend to be half days.
    half_day_array = ["2015-11-27", "2015-12-24", "2016-11-25", "2016-12-23", "2017-11-24", "2018-11-23", "2018-12-24"]

    string_date = CustomDate.utc_time_to_string(utc_time)
    holiday_format = Date.strptime(string_date.to_s).strftime("%Y-%m-%d")
    hour_format = string_date.strftime("%H:%M")

    if string_date.wday == 6 || string_date.wday == 0
      return true
    end

    if hour_format < "09:30" || hour_format > "16:00"
      return true
    end

    if holiday_array.include? holiday_format
      return true
    end

    if half_day_array.include? holiday_format
      if hour_format < "09:30" || hour_format > "13:00"
        return true
      end
    end

  end

end
