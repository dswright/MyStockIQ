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

function DailyPredictions (predictions, min_time) {
  prediction_array = [];
  predictions.forEach(function(element, index, arr) {
    if (element[0] < min_time) { //if the prediction time is less than the minimum time amount (the end of the daily stock data), reset the prediction time for the graph.
      prediction_array.push([min_time, element[1]]);
    }
    else {
      prediction_array.push([element[0],element[1]]);
    }
  });
  return prediction_array;
}

function IntradayButton (prices, predictions) {
  this.timeInterval = 60*5*1000;
  this.timeLength = 6.5*3600*1000;
  this.prices = prices;
  this.predictions = predictions;
}

function DailyButton (prices, predictions) {
  this.timeInterval = 24*3600*1000;
  this.timeLength = 24*3600*1000;
  this.prices = prices;
  this.predictions = predictions;
}

//graphSettings passes in: intraday_prices, predictions, daily_prices. For use in the buttonsettings.
//this function creates the buttons for the graph.
function StockGraphButtons(graphSettings) {
  var intradayButton = new IntradayButton(graphSettings["intradayPrices"], graphSettings["predictions"]);
  var dailyButton = new DailyButton(graphSettings["dailyPrices"], graphSettings["predictions"]);
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
  var intradayButton = new IntradayButton(graphSettings["intradayPrices"], graphSettings["predictions"]);
  var dailyButton = new DailyButton(graphSettings["dailyPrices"], graphSettings["predictions"]);
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


//settings consist of buttonname, 
function Button(buttonSettings) {
  var beforeDays = buttonSettings["beforeDays"];
  var afterDays = buttonSettings["afterDays"];
  var settings = buttonSettings["settings"]; //contains 4 items: timeInterval, timeLength, prices, predictions
  
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
  var limitedPredictions = limitedArray(settings.predictions); //The predictions that fall into the x axis time frame.
  var limitedPrices = limitedArray(settings.prices); //The stock prices that fall into the x axis time frame.

  
  function yMin(prices, predictions) { 
    var min = prices.reduce(function (min, obj) {  //this reduce function needs to get the lowest price from the array.
      return obj[1] < min ? obj[1] : min; //if obj[1] (price) is less than the min, return obj[1], otherwise return min. 
    }, Infinity); //infinity is the value of the first min.
    var minPriceFinal = min;
    
    predictions.forEach(function (value, index, arr) {
      if (value[1] < minPriceFinal) {
        if (value[1] > min * 0.4) {
          minPriceFinal = value[1] * 0.95;
        }
      }
    });
    return minPriceFinal;
  }

  function yMax(prices, predictions) {
    var max = prices.reduce(function (max, obj) {
      return obj[1] > max ? obj[1] : max;
    }, 0);
    var maxPriceFinal = max;

    predictions.forEach(function (value, index, arr) {
      if (value[1] > maxPriceFinal) {
        if (value[1] < max * 2.5) {
          maxPriceFinal = value[1] * 1.05;
        }
      }
    });
    return maxPriceFinal;
  }
  this.yMin = yMin(limitedPrices, limitedPredictions);  
  this.yMax = yMax(limitedPrices, limitedPredictions);

} //for some reason this paren doesn't underline, but it does close the Button class.
