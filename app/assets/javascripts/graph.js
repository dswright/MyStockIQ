if(!Array.prototype.last) {
    Array.prototype.last = function() {
        return this[this.length - 1];
    }
}

if (!Array.prototype.reduce) {
  Array.prototype.reduce = function(callback , initialValue) {
    'use strict';
    if (this == null) {
      throw new TypeError('Array.prototype.reduce called on null or undefined');
    }
    if (typeof callback !== 'function') {
      throw new TypeError(callback + ' is not a function');
    }
    var t = Object(this), len = t.length >>> 0, k = 0, value;
    if (arguments.length == 2) {
      value = arguments[1];
    } else {
      while (k < len && ! k in t) {
        k++; 
      }
      if (k >= len) {
        throw new TypeError('Reduce of empty array with no initial value');
      }
      value = t[k++];
    }
    for (; k < len; k++) {
      if (k in t) {
        value = callback(value, t[k], k, t);
      }
    }
    return value;
  };
}

Array.prototype.select = function(closure){
  var new_array = [];
  for(var n = 0; n < this.length; n++) {
    if(closure(this[n])){
        new_array.push(this[n]);
    }
  }
  return new_array;
}

function DailyPredictions (predictions, min_time) { //make this function take an array of shit and transform it into the end times.
  var prediction_array = [];
  for(var i = 0; i < predictions.length; i++ ) {
    if (predictions[i][0] < min_time) {
      prediction_array.push([min_time, predictions[i][1]]);
    }
    else {
      prediction_array.push([predictions[i][0], predictions[i][1]]);
    }
  }
  return prediction_array
}

function DailyPredictions (predictions, predictions_ids) { //the predictions array just has times and prices... these need to be converted?
  //these will be in order of time... so just check the one before to see if it is the same day as the current one?
  //If it is the same day... then don't add it. If its a different day, then add it.
  //Should also set the time of the prediction to the 21:00 mark to align with the forward array...
  var predictions_array = [];
  var predictions_ids_array = [];
  for(var i=0; i < predictions.length; i++ ) {
    var timeStr = predictions[i][0].utcTimeInt().utcTimeStr(); //convert the graph time into a utc date string.
    var day = timeStr.utcTime().utcTimeStr(); //convert the date string into string 'yyyy-mm-dd'
    day = day + " 16:00:00"; //
    var timeCompare = day.utcTime().utcTimeInt().graphTimeInt(); //convert the string to datestamp, then to utc int, then graphtimeint.
    
    if (predictions_array.last() === undefined) {
      predictions_array.push([timeCompare, predictions[i][1]]);
      predictions_ids_array.push(predictions_ids[i]);
    }
    else if (predictions_array.last()[0] !== timeCompare ) {
      predictions_array.push([timeCompare, predictions[i][1]]);
      predictions_ids_array.push(predictions_ids[i]);
    }
  }
  return [predictions_array, predictions_ids_array];
}

//make a my prediction function that overwrites the DailyPredictions function.

function IntradayButton (prices, predictions, myPrediction) {
  this.timeInterval = 60*5*1000;
  this.timeLength = 6.5*3600*1000;
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

function DailyButton (prices, predictions, myPrediction) {
  this.timeInterval = 24*3600*1000;
  this.timeLength = 24*3600*1000;
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

function BestRange (endTime, rangeHash) {
  for (var value in rangeHash) { //loop through the values of the rangehash - 1d, 5d, 1m ect..
    if (endTime < rangeHash[value]["xMax"]) { //if the endTime is less than the x max of the range, then its in range.
      return value; //return that value, ie, the button name - "1d", "5d" ect.
    }
  }
}

//returns an array of time time and price variables.
//used to look into the future on the graph.
//intraday forward array currently looks ahead 3 days arbitrarily. The exact ahead time would be 2.5 days.
//The actual target setting is controlled with the x axis settings.
function IntradayForwardPrices (startTime) {
  forwardArray = [];
  var i=0;
  var iterations = 390; //5 6.5 hour days of 5 minute itarations. 5 days necessary for the prediction details graph.
  while (i<=iterations) {
    timeSpot = startTime + i*5*60*1000;
    if (timeSpot.utcTimeInt().utcTimeStr().validStockTime()) {
      forwardArray.push([timeSpot, null]);
    }
    else {
      iterations += 1;
    }
    i += 1;
  }
  return forwardArray;
}


  //end time is assumed to be an est number.
  //the graph start time int is the end of the actual data array.
  //whether that be the daily array or the intraday array, it gets the last day of data..
function DailyForwardPrices (startTime) {
  var forwardArray = [];
  var i = 0;
  var iterations = 1202; //cut this in half for testing purpses..
  while (i<=iterations) {
    timeSpot = startTime + i*24*3600*1000;
    if (timeSpot.utcTimeInt().utcTimeStr().validStockTime()) {
      forwardArray.push([timeSpot, null]);
    }
    else {
      iterations += 1;
    }
    i += 1;
  }
  return forwardArray;
}


//graphSettings passes in: intraday_prices, predictions, daily_prices. For use in the buttonsettings.
//this function creates the buttons for the graph.
function StockGraphButtons(graphSettings) {
  var intradayButton = new IntradayButton(graphSettings["intradayPrices"], graphSettings["predictions"], graphSettings["myPrediction"]);
  var dailyButton = new DailyButton(graphSettings["dailyPrices"], graphSettings["predictions"], graphSettings["myPrediction"]);
  var buttons = [{name:"1d", beforeDays:1, afterDays:0.5, settings:intradayButton},
                        {name:"5d", beforeDays:5, afterDays:2.5, settings:intradayButton},
                        {name:"1m", beforeDays:20, afterDays:10, settings:dailyButton},
                        {name:"3m", beforeDays:60, afterDays:30, settings:dailyButton},
                        {name:"6m", beforeDays:120, afterDays:60, settings:dailyButton},
                        {name:"1yr", beforeDays:240, afterDays:120, settings:dailyButton},
                        {name:"5yr", beforeDays:1200, afterDays:600, settings:dailyButton}];
  var rangeHash = {};
  buttons.forEach(function (element, index, array) {
    var button = new Button(element);
    rangeHash[element["name"]] = {"xMin":button.xMin, "xMax":button.xMax, "yMin":button.yMin, "yMax":button.yMax};
  });
  return rangeHash;
}

function PredictionGraphButtons(graphSettings) {
  var intradayButton = new IntradayButton(graphSettings["intradayPrices"], graphSettings["predictionend"], graphSettings["myPrediction"]); //the 'endprediction' is input here, hereon refered to as 'predictions'
  var dailyButton = new DailyButton(graphSettings["dailyPrices"], graphSettings["predictionend"], graphSettings["myPrediction"]);
  var buttons = [{name:"1d", beforeDays:0.5, afterDays:1, settings:intradayButton},
                        {name:"5d", beforeDays:2.5, afterDays:5, settings:intradayButton},
                        {name:"1m", beforeDays:10, afterDays:20, settings:dailyButton},
                        {name:"3m", beforeDays:30, afterDays:60, settings:dailyButton},
                        {name:"6m", beforeDays:60, afterDays:120, settings:dailyButton},
                        {name:"1yr", beforeDays:120, afterDays:240, settings:dailyButton},
                        {name:"5yr", beforeDays:600, afterDays:1200, settings:dailyButton}];
  var rangeHash = {};
  buttons.forEach(function (element, index, array) {
    var button = new Button(element);
    rangeHash[element["name"]] = {"xMin":button.xMin, "xMax":button.xMax, "yMin":button.yMin, "yMax":button.yMax};
  });
  return rangeHash;
}

//return the full suite of correct buttons by passing in some parameters...
//This should distinguish between the two main graphs...
//So the settings should pass in the buttons it wants processed.
//The json feed should pass back the correct arrays. Those don't need to be built.
//Xmin and x max calculations will be different for the two different graphs.
//So that needs to be indicated, or it could just be indicated with the button settings..
//The start and stop times should be used to specify those.. Not too hard..


function ChartFunctions(graph, chart) {
  this.startChart = function() {
    chart.series[0].setData(graph["daily_prices"]);
    chart.series[1].setData(graph["daily_forward_prices"]);
    chart.series[2].setData(graph["daily_predictions"]);
  };
}


function Button(buttonSettings) {
  var beforeDays = buttonSettings["beforeDays"];
  var afterDays = buttonSettings["afterDays"];
  var settings = buttonSettings["settings"]; //contains 4 items: timeInterval, timeLength, prices, predictions, myPrediction
  
  //intervalDirection is the direction to move from the start point.
  //startpoint is where to start counting from.
  //timeWindow is the total amount of time to look over. 5 days, 1 yr, ect.
  function EndPoint (intervalDirection, startPoint, timeWindow) { //startPoint is exepcted to be in graphtime.
    timeLength = settings.timeLength * timeWindow; //calculate the total time to iterate over.
    var i=0;
    iterations = timeLength/settings.timeInterval; //calculate number of iterations
    while (i<=iterations) {
      var time_to_check = (startPoint + i*settings.timeInterval*intervalDirection).utcTimeInt().utcTimeStr(); //convert the graphtime int to utc time int, then to utc time string for processing.
      if (!time_to_check.validStockTime()) { //validstocktime function expects a string.
        iterations += 1; //if this time point is invalid, increase the number of iterations to do.
      }
      i+=1; //increase i everytime.
    }
    endPoint = startPoint + settings.timeInterval*iterations*intervalDirection;
    return endPoint;
  }

  var startPoint = settings.prices.last()[0];

  this.xMin = EndPoint(-1, startPoint, beforeDays); //get the xMin from the endpoint function.
  this.xMax = EndPoint(1, startPoint, afterDays);

  var xMinVar = this.xMin; //the min x time for this button.
  var xMaxVar = this.xMax; //the max x time for this button.
  
  function limitedArray(graphArray) {
    var returnArray = graphArray.select(function(point) {
      if (point[0] >= xMinVar && point[0] <= xMaxVar){
        return point;
      }
    });
    if (returnArray === undefined) {
      return [];
    }
    else {
      return returnArray;
    }
  }
  var limitedPrices = limitedArray(settings.prices); //The stock prices that fall into the x axis time frame.
  var limitedPredictions = limitedArray(settings.predictions); //The predictions that fall into the x axis time frame.
  var limitedMyPrediction = limitedArray(settings.myPrediction);

  
  function yMin(prices, predictions, myPrediction) { 
    var min = prices.reduce(function (min, obj) {  //this reduce function needs to get the lowest price from the array.
      return obj[1] < min ? obj[1] : min; //if obj[1] (price) is less than the min, return obj[1], otherwise return min. 
    }, Infinity); //infinity is the value of the first min.
    var minPriceFinal = min;
    predictions.forEach(function (value, index, arr) { //sets the min price that other people predictions will adjust the graph by.
      if (value[1] < minPriceFinal) {
        if (value[1] > min * 0.5) { //the min is 50% of the graph min price.
          minPriceFinal = value[1];
        }
      }
    });
    myPrediction.forEach(function (value, index, arr) { //the user's own prediction will always show up.
      if (value[1] < minPriceFinal) {
        minPriceFinal = value[1];
      }
    });
    return minPriceFinal-(min-minPriceFinal)*0.05; //decrease the min by an extra 5% of the difference of the adjustment. 
  }

  function yMax(prices, predictions, myPrediction) {
    var max = prices.reduce(function (max, obj) {
      return obj[1] > max ? obj[1] : max;
    }, 0);
    var maxPriceFinal = max;

    predictions.forEach(function (value, index, arr) { //this controls the max view for seeing predicitons.
      if (value[1] > maxPriceFinal) {
        if (value[1] < max * 1.5) { //the limit is currently set to 1.5 times the max stockprice point.
          maxPriceFinal = value[1];
        }
      }
    });
    myPrediction.forEach(function (value, index, arr) { //there is no limit for the myPrediction. It will always show.
      if (value[1] > maxPriceFinal) {
        maxPriceFinal = value[1];
      }
    });
    return maxPriceFinal+(maxPriceFinal-max)*0.05;
  }

  this.yMin = yMin(limitedPrices, limitedPredictions, limitedMyPrediction);  
  this.yMax = yMax(limitedPrices, limitedPredictions, limitedMyPrediction);

} //for some reason this paren doesn't underline, but it does close the Button class.
