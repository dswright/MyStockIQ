class CustomDate
  
  #this takes a date in the form of - "2014-12-16 00:00:00 UTC" and converts to the utc time stamp like 13242342309203
  def self.utc_time(date_string)
    utc_time = Time.parse(date_string).getutc.to_time.to_i * 1000
  end

  def self.utc_time_to_string(utc_time)
    date_string = Time.at(utc_time/1000)
  end

end
