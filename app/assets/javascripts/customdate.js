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

//This takes string of the types (Must have GMT):
//"2013-02-06 21:00:00 GMT" - for manual date input types.
//Wed, 06 Feb 2013 21:00:00 GMT" - for processing graphtimes turned into datestrings.
//"2013-02-06T21:00:00.000Z" - for processing datestamps taken straight from the database.
String.prototype.graphTime = function() {
  return Date.parse(this);
}

//this takes the a string of the form "Wed, 06 Feb 2013 21:00:00 GMT" and returns the format "2013-02-06"
String.prototype.dayString = function() {
  var d = new Date(this); //converts string into JS Date.
  return moment(d).utc().format("YYYY-MM-DD"); //converts the JS Date to the daily format.
}

//This converts a graphtime number "1360184400000" into a GMT string "Wed, 06 Feb 2013 21:00:00 GMT"
Number.prototype.gmtString = function() {
  return new Date(this).toUTCString();
}

//add the EST moment as a timezone.
moment.tz.add('America/New_York|EST EDT|50 40|0101|1Lz50 1zb0 Op0');

//this offsetTime returns an hour if the UTC time is 20:00:00, and returns nothing if the utc time is 21:00:00. (stock market end time is EST)
Number.prototype.offsetTime = function() {
  //the America/New York timezone is set just outside of this function.
  var offset = moment.tz.zone('America/New_York').offset(this) * 60 * 1000; //the offset is returned as a positive number of minutes, which converted to milliseconds.
  return 5*3600*1000 - offset; //This will return either 0 or 3600*1000 millisecond (1 hour) offset, depending on DST.
}

//This takes graphtime as the correct intake.
Number.prototype.validStockTime = function() {
  
  //this takes the a string of the form "Wed, 06 Feb 2013 21:00:00 GMT" and returns the format "21:00:00"
  function hourString(str) {
    var d = new Date(str); //converts string to JS Date.
    return moment(d).utc().format("HH:mm:ss"); //converts the JS Date to the hour format.
  }

  //this takes a string of the form "Wed, 06 Feb 2013 21:00:00 GMT" and returns the weekday number, like 6 or 7.
  function weekDay(str) {
    var d = new Date(str)
    return moment(d).isoWeekday();
  }

  //This is the array of holiday dates that the market is closed.
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

  //This is the array of holidays that the market is open until just 1pm.
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

  //first thing to do is to detect the offset that exists with this graphtime.  
  var offsetTime = this + this.offsetTime(); //this either increases by 1 hour, or not at all.


  //now use that offsetTime to create the string to run verificaitons against.
  var gmtStr = offsetTime.gmtString();

  
  var holidayFormat = gmtStr.dayString(); //converts to YYYY-MM-DD
  var hourFormat = hourString(gmtStr); //converts to "HH:mm:ss" type.


  if (weekDay(gmtStr) == 6 || weekDay(gmtStr) == 7) { //if the day is on a weekend, its invalid day.
    return false;
  }

  if (hourFormat < "14:30:00" || hourFormat > "21:00:00") { //if its outside of market hours, its invalid. validation times are in utc time, 5 hours ahead of est.
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
