if (![].includes) {
  Array.prototype.includes = function(searchElement /*, fromIndex*/ ) {'use strict';
    var O = Object(this);
    var len = parseInt(O.length) || 0;
    if (len === 0) {
      return false;
    }
    var n = parseInt(arguments[1]) || 0;
    var k;
    if (n >= 0) {
      k = n;
    } else {
      k = len + n;
      if (k < 0) {k = 0;}
    }
    var currentElement;
    while (k < len) {
      currentElement = O[k];
      if (searchElement === currentElement ||
         (searchElement !== searchElement && currentElement !== currentElement)) {
        return true;
      }
      k++;
    }
    return false;
  };
}

String.prototype.utcTime = function() { //takes date string format of the manual type "YYYY-MM-DD" or the database type "2015-01-26 21:00:00 UTC".
  var dateString = this;
  if (dateString.indexOf(':') === -1) { //if there is no ':', add the minute string.
    dateString = dateString + " 00:00:00";
  }
  arr = dateString.split(/[- :]/);
  theDate = new Date(arr[0], arr[1]-1, arr[2], arr[3], arr[4], arr[5]); //returns a date stamp.
  //return new Date(theDate.getUTCFullYear(), theDate.getUTCMonth(), theDate.getUTCDate(), theDate.getUTCHours(), theDate.getUTCMinutes(), theDate.getUTCSeconds()); //returns a datestamp.
  return new Date(arr[0], arr[1]-1, arr[2], arr[3], arr[4]-theDate.getTimezoneOffset(), arr[5]);
}

Date.prototype.utcTimeInt = function() {
  return this.getTime(); //convert a date type into a UTC int.
}

Date.prototype.weekDay = function() {
  return moment(this).isoWeekday();
}

Date.prototype.utcTimeStr = function() {
  return moment(this).utc().format("YYYY-MM-DD"); //convert date type into a day string.
}

Date.prototype.utcTimeHour = function() {
  return moment(this).utc().format("HH:mm:ss"); //convert date type into an hour string.
}

Number.prototype.utcTimeStr = function() {
  return moment.utc(this*1000).format("YYYY-MM-DD HH:mm:ss UTC"); //convert an integer into a utc date string.
}

Number.prototype.graphTimeInt = function() {
  return (this-5*3600) * 1000; //converts the time into to milliseconds and EST.
}

Number.prototype.utcTimeInt = function() {
  return this/1000 + 5*3600; //converts the time from graph time to the regular UTC time int.
}

//expects to take a date string "YYYY-MM-DD" or the database type "2015-01-26 21:00:00 UTC"
String.prototype.validStockTime = function() {
  //standard whole holidays are:
  //new years day, MLK day, Presidents day, Good Friday, Memorial Day, July 4th, Labor Day, Thanksgiving, Christmas
  
  var holidayArray = [
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
  ];

  //Friday after thanksgiving and Christmas eve, when on a weekday, tend to be half days.
  var halfDayArray = [
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
  ];

  var utcTime = this.utcTime(); //converts the time string into a time stamp.
  var holidayFormat = utcTime.utcTimeStr(); //converts to YYYY-MM-DD
  var hourFormat = utcTime.utcTimeHour(); //converts to "HH:mm:ss" type.

  //hourformat uses the utcTime... what is this??? this is the string that the function is applied to..
  //string is of type '2015-03-10 21:00:00 UTC'

  if (utcTime.weekDay() == 6 || utcTime.weekDay() == 7) { //if the day is on a weekend, it is not a valid day.
    return false;
  }

  if (hourFormat < "14:30:00" || hourFormat > "21:00:00") { //if its outside of market hours, it invalid. validation times are in utc time, 5 hours ahead of est.
    return false;
  }

  if (holidayArray.includes(holidayFormat)) { //if the day is a holiday, its invalid.
    return false;
  }

  if (halfDayArray.includes(holidayFormat)) {
    if (hourFormat < "14:30:00" || hourFormat > "18:00:00") { //if the day is halfday, and not in the 4 hour open window, then its invalid. validation times are in utc time, 5 hours ahead of est.
      return false;
    }
  }


  return true;
}
