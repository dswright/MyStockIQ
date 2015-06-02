
var TimeMaker = function(selectTime) { //pass in the selected time from the calendar.

  this.dayStart = function() {
    var input = new Date(selectTime.gmtString()); //puts the input time into a date timestamp.
    var offSet = input.getTimezoneOffset(); //gets the offset from the datestamp.
    var newStart = selectTime - offSet*60*1000; //subtracts that timezone difference to get the real gmt as an integer.
    return newStart; //returns the gmt daystart time as a number.
  };
  this.startTime = this.dayStart();

  this.timeFormSetter = function() {
    if ((this.startTime+19*1000*3600).validStockTime()) { //add 19 hours because its a valid afternoon time. Check if its valid. If its not, it means that the selected day is a half day. Holidays are blocked dates by the calendar.
      $('#timepicker').val('4:00 PM');
    }
    else {
      $('#timepicker').val('1:00 PM');
    }
  };

  this.updateTimePicker = function(picker, timeVars) { //update the timepicker after it has loaded on the page already.
    //timeVars passes in a variety of variables for the current time. Like EST in hour format.
    var currentDay = new Date().toJSON().slice(0,10); //get the current day without the timezone offset.
    var currentGT = currentDay.graphTime();

    picker.set('min', [9,30]);

    if (currentGT === this.dayStart()) { //if the selected time is the same as today
      // if the current time is less than 9:30 EST, then set the min to 9:30.

      if (timeVars.hourFormat < "09:30:00") {
        picker.set('min', [9,30]);
      }
      else {
        var estGT = timeVars.est; //get current time in est.
        var estD = new Date(estGT.gmtString()); //turn the time into a date stamp.
        var estOffset = estD.getTimezoneOffset(); //get the timezone offset of that time.
        var estDInLocal = new Date((estGT+estOffset*60*1000).gmtString()); //get the date stamp into est, regardless of timezone.
        var minutes = estDInLocal.getMinutes(); //get the minutes from the est timestamp.
        var hours = estDInLocal.getHours(); //get the hours from the est timestamp.
        if (minutes >= 30) {
          minMinutes = 0;
          hours += 1; //if minutes is greater than 0, add 1 to hours.
        }
        else {
          minMinutes: 30;
        }
        var minMinutes = (minutes>=30 ? 0 : 30);
        picker.set('min',[hours, minMinutes]);

      }
    }
    if (!(this.dayStart()+19*3600*1000).validStockTime()) { //add 19 hours because valid stock time takes graphtime in gmt.
      picker.set('max',[13,0]);
    }
    else {
      picker.set('max',[16,0]);
    }
  };
}


var CalVars = function(date) { //pass in a date var
  this.graphTime = date.toString().graphTime(); //returns the graphTime in GMT.

  this.offset = this.graphTime.offsetTime(); //gets a 1 hour or 0 hour offset time in graphtime format.

  this.est = this.graphTime - (5*3600*1000 - this.offset); //subtract 5 hours when 21, and 4 hours when 20.
  console.log("est of current:"+this.est);

  this.hourComparison = function() { 
    if (this.dayType == "half") {
      this.hourLimit = "13:00:00";
    }
    else {
      this.hourLimit = "16:00:00";
    }
  }
  this.hourComparison(); //run this hour comparison to set the hour limit in the TimeVars object.

  this.hourFormat = this.est.hourString();

  this.dayStatus = function(est) {
    var validDay = est + 15 * 3600*1000 //put the time at 10 AM in GMT, it should return as true if its a valid day.
    var validAfternoon = est + 19 * 3600*1000 //put the time at 3PM GMT, should return false if its a half day.
    if (validDay.validStockTime){
      if (validAfternoon.validStockTime) {
        return "normal";
      }
      else {
        return "half";
      }
    }
    else {
      return "invalid";
    }
  };

  this.dayType = this.dayStatus(this.est); //gets set to either invalid, normal, or half.
}

var CalendarMaker = function(timePicker) {
  var timeVars = new CalVars(new Date()); //timeVar options get set using the current date.
  console.log(timeVars);

  this.picker = timePicker; //picker gets set once TimeMaker is called. Could the same function be used at start at and selection? Not really.. timepicker update assumes a valid date has been selected.

  this.setMinTime = function(est) { //this needs to detect if the selected day is a half day.
  
    if (this.dayState == "invalid") {
      this.minTime = new Date(timeVars.est.gmtString()); //if the current day is invalid, use the currentDay as the min time.
    }
    else { //if the current day is valid, check to see 
      if (timeVars.hourFormat < timeVars.hourLimit) { //if its during trading hours.
        this.minTime = new Date(timeVars.est.gmtString()); //if it is, use the est of the current time to set the min.
      }
      else { //if its not, use tomorrow as the day min.
        this.minTime = new Date((timeVars.est + 24*3600*1000).gmtString()); //add a whole day to the current day to set tmrw as the min.
      }
    }
  };
  this.setMinTime();

  this.dateObject = {
    disable: [
      1,7, //disable all weekends.
      //this is the holiday array to remove dates. Months are set 0-11, not 1-12.
      [2010,00,01], [2010,00,18], [2010,01,15], [2010,03,02], [2010,04,31], [2010,06,05], [2010,08,06], [2010,10,25], [2010,11,24],
      [2011,00,17], [2011,00,21], [2011,03,22], [2011,04,30], [2011,06,04], [2011,08,05], [2011,10,24], [2011,11,26],
      [2012,00,02], [2012,00,16], [2012,01,20], [2012,03,06], [2012,04,28], [2012,06,04], [2012,08,03], [2012,10,22], [2012,11,25],
      [2013,00,01], [2013,00,21], [2013,01,18], [2013,02,29], [2013,04,27], [2013,06,04], [2013,08,02], [2013,10,28], [2013,11,25],
      [2014,00,01], [2014,00,20], [2014,01,17], [2014,03,18], [2014,04,26], [2014,06,04], [2014,08,01], [2014,10,27], [2014,11,25],
      [2015,00,01], [2015,00,19], [2015,01,16], [2015,03,03], [2015,04,25], [2015,08,07], [2015,10,26], [2015,11,25],
      [2016,00,01], [2016,00,18], [2016,01,15], [2016,02,25], [2016,04,30], [2016,06,04], [2016,08,05], [2016,10,24], [2016,11,26],
      [2017,00,02], [2017,00,16], [2017,01,20], [2017,03,14], [2017,04,29], [2017,06,04], [2017,08,04], [2017,10,23], [2017,11,25],
      [2018,00,01], [2018,00,15], [2018,01,19], [2018,02,30], [2018,04,28], [2018,06,04], [2018,08,03], [2018,10,22], [2018,11,25],
      [2019,00,01], [2019,00,21], [2019,01,18], [2019,03,19], [2019,04,27], [2019,06,04], [2019,08,02], [2019,10,28], [2019,11,25],
      [2020,00,01], [2020,00,20], [2020,01,17], [2020,03,10], [2020,04,25], [2020,06,03], [2020,08,07], [2020,10,26], [2020,11,25]
    ],
    min: this.minTime,
    onSet: function(context) {
      if (context.select != undefined) {
        console.log(context.select);
        //context.select passes time as a number (1432623600000), which is the beginning of the day in local time.
        timeUpdate = new TimeMaker(context.select);
        timeUpdate.timeFormSetter(); //timeFormSetter sets the forms end time. Must be done when this is selected..
        timeUpdate.updateTimePicker(timePicker, timeVars);
      }
    }
  };
  $('#datepicker').pickadate(this.dateObject);
}



// var tOM = function() { //timeObjectMaker
//   var inputTime;

//   var maxT = [16,0];
//   var minT, currentDay, currentGT;

//   if (gDayForTimeSelection == undefined) {
//     minT = [9,30];  
//   }
//   else {
//     //convert currentDay into gmt time. Check if the time is less than 9:30 EST. If so, minT is 9 30, else if time less than 4 PM, or 1pm on half days, then make the min time based on 30 minute increments.
//     currentDay = new Date().toJSON().slice(0,10); //returns the current day in in string form "2015-05-21". This is messed up because it retuns may 21st, when today is still the 20th. Need to check the time of tomorrow, check if it is less than 9 AM, if it, then do the day rounding thing. which isnt working anyway! blah. Need to fix that to round correctly also.
//     currentGT = currentDay.graphTime(); //gives the graph time.
//     if (gDayForTimeSelection === currentGT) { //if the current day is the selected day...
//       var newD = new Date();
//       var minutes = newD.getMinutes();
//       var minMinutes = (minutes>=30 ? 0 : 30);
//       minT = [minMinutes, newD.getHours()];
//     }
//     else {
//       minT = [9,30];
//     }

//     if (!(gDayForTimeSelection+19*3600*1000).validStockTime()){ //add 19 hours because valid stock time takes graphtime in gmt.
//       maxT = [13,0];
//     }
//   }
//   console.log("MIN:"+minT);
//   return {
//     min: minT,
//     max: maxT
//   };
// };

