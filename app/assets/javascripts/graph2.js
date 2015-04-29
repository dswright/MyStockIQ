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



function IntradayButton (prices, predictions, myPrediction) {
  this.timeInterval = 60*5*1000;
  this.timeLength = 6.5*3600*1000;
  this.startPoint = prices.last()[0]; //the start point is the end of the intradayPrices array.
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

function DailyButton (prices, predictions, myPrediction) {
  this.timeInterval = 24*3600*1000;
  this.timeLength = 24*3600*1000;
  this.startPoint = prices.last()[0]; //the start point is the end of the dailyPrices array.
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

//graphSettings passes in: intraday_prices, predictions, daily_prices. For use in the buttonsettings.
//this function creates the buttons for the graph.
function StockGraphButtons(graphSettings) {
  var intradayButton = new IntradayButton(graphSettings["intradayPrices"], graphSettings["predictions"], graphSettings["myPrediction"]);
  var dailyButton = new DailyButton(graphSettings["dailyPrices"], graphSettings["predictions"], graphSettings["myPrediction"]);
  var buttons = [{name:"1D", beforeDays:1, afterDays:0.5, settings:intradayButton},
                        {name:"5D", beforeDays:5, afterDays:2.5, settings:intradayButton},
                        {name:"1M", beforeDays:20, afterDays:10, settings:dailyButton},
                        {name:"3M", beforeDays:60, afterDays:30, settings:dailyButton},
                        {name:"6M", beforeDays:120, afterDays:60, settings:dailyButton},
                        {name:"1Yr", beforeDays:240, afterDays:120, settings:dailyButton},
                        {name:"5Yr", beforeDays:1200, afterDays:600, settings:dailyButton}];
  var rangeHash = {};
  buttons.forEach(function (element, index, array) {
    var button = new Button(element);
    rangeHash[element["name"]] = {"xMin":button.xMin, "xMax":button.xMax, "yMin":button.yMin, "yMax":button.yMax};
  });
  return rangeHash;
}

//DUPS
function PredictionIntradayButton (prices, predictions, myPrediction) {
  this.timeInterval = 60*5*1000;
  this.timeLength = 6.5*3600*1000;
  this.startPoint = myPrediction[0][0]; //the start point is the first point in the myPrediction array .
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

function PredictionDailyButton (prices, predictions, myPrediction) {
  this.timeInterval = 24*3600*1000;
  this.timeLength = 24*3600*1000;
  this.startPoint = myPrediction[0][0]; //the start point is the first poin in the myPrediction array.
  this.prices = prices;
  this.predictions = predictions;
  this.myPrediction = myPrediction;
}

function PredictionGraphButtons(graphSettings) {
  var intradayButton = new PredictionIntradayButton(graphSettings["intradayPrices"], graphSettings["predictions"], graphSettings["intradayPrediction"]); //the 'endprediction' is input here, here to refered to as 'predictions'
  var dailyButton = new PredictionDailyButton(graphSettings["dailyPrices"], graphSettings["predictions"], graphSettings["dailyPrediction"]); //the 'myprediction' is rounded to appropriate days for each button set.
  var buttons = [{name:"1D", beforeDays:1, afterDays:0.5, settings:intradayButton},
                        {name:"5D", beforeDays:5, afterDays:2.5, settings:intradayButton},
                        {name:"1M", beforeDays:20, afterDays:10, settings:dailyButton},
                        {name:"3M", beforeDays:60, afterDays:30, settings:dailyButton},
                        {name:"6M", beforeDays:120, afterDays:60, settings:dailyButton},
                        {name:"1Yr", beforeDays:240, afterDays:120, settings:dailyButton},
                        {name:"5Yr", beforeDays:1200, afterDays:600, settings:dailyButton}];
  var rangeHash = {};
  buttons.forEach(function (element, index, array) {
    var button = new Button(element);
    rangeHash[element["name"]] = {"xMin":button.xMin, "xMax":button.xMax, "yMin":button.yMin, "yMax":button.yMax};
  });
  return rangeHash;
}

function PredictionDetails(graph, chart) {

  graph["intraday_prediction"] = IntradayPredictions(graph["prediction"], undefined)[0]; //the 0 says to return only the first element of the returned value, which is an array of 2 objects.
  graph["daily_prediction"] = DailyPredictions(graph["prediction"], undefined)[0]; //the extra array of 0s is there for the prediction ids processor, which is an array of 2 objects.
  graph["intraday_predictionend"] = IntradayPredictions(graph["predictionend"], undefined)[0]; //the undefined indicates that these are for the prediction details page. The undefined normally takes the predictionids_string.
  graph["daily_predictionend"] = DailyPredictions(graph["predictionend"], undefined)[0];


  var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:[[0,0]], myPrediction:graph["prediction"], intradayPrediction:graph["intraday_prediction"], dailyPrediction:graph["daily_prediction"]};
  var rangeHash = new PredictionGraphButtons(graphSettings);

  this.startChart = function() {
    graph["daily_forward_prices"] = DailyForwardPrices(graph["daily_prices"].last()[0]);
    graph["intraday_forward_prices"] = IntradayForwardPrices(graph["intraday_prices"].last()[0]);

    var endTime = graph["prediction"].last()[0]; //use the endTime of the users own prediction to get the best range.
    var bestButton = BestRange(endTime);

    if (bestButton === "1D" || bestButton === "5D") {
      currentRange["buttonType"] = "1M";
    }
    else {
      currentRange["buttonType"] = "5D";
    }

    setSeries(bestButton); //set the graphs to start.
    setRange(bestButton);


    //update the selected state of the time range for the current range.
    $('*[data-button-type="'+currentRange["buttonType"]+'"]').switchClass("timeframe-item", "timeframe-item-selected");

  }

  this.buttonClick = function() {
    var buttonType = $(this).data("button-type");
    setSeries(buttonType); //always set series before range. Resets all series arrays if there is a button type change.
    setRange(buttonType);

    //change the on-hover states based on what has been clicked.
    $(".timeframe-item-selected").switchClass("timeframe-item-selected", "timeframe-item")
    $(this).switchClass("timeframe-item", "timeframe-item-selected");
    
  }

  this.endPrediction = function(endTime, endPrice) { //endtime and price are passed by the ajax function.
    //need to set the endprediction line.
    //need to change the formatting on the first prediction line.
    //probably need to handle situation of overlapaping lines.
    //need to reset the endprediction line 

    graph["predictionend"] = [[graph["prediction"][0][0], graph["prediction"][0][1]],[endTime, endPrice]];
    graph["intraday_predictionend"] = IntradayPredictions(graph["predictionend"], undefined)[0];
    graph["daily_predictionend"] = DailyPredictions(graph["predictionend"], undefined)[0];

    if (currentRange["buttonType"] === "1D" || currentRange["buttonType"] === "5D") {
      chart.series[3].setData(graph["intraday_predictionend"]); //instead of resetting all series', just reset this one.
    }
    else {
      chart.series[3].setData(graph["daily_predictionend"]); //instead of resetting all series', just reset this one.
    }
  }

  function setSeries(button) {
    if ((button !== "1D" && button !== "5D") && (currentRange["buttonType"] === "1D" || currentRange["buttonType"] === "5D")) { //set daily graph
      chart.series[0].setData(graph["daily_prices"]); //all of these need to be set based on the button of best fit.
      chart.series[1].setData(graph["daily_forward_prices"]);
      chart.series[2].setData(graph["daily_prediction"]); //need the daily prediction and intraday predictions
      chart.series[3].setData(graph["daily_predictionend"]); //same with this. maybe null.
    }
    if ((button === "1D" || button === "5D") && (currentRange["buttonType"] !== "1D" && currentRange["buttonType"] !== "5D")) { //set intraday graph arrays
      chart.series[0].setData(graph["intraday_prices"]); //all of these need to be set based on the button of best fit.
      chart.series[1].setData(graph["intraday_forward_prices"]);
      chart.series[2].setData(graph["intraday_prediction"]); //need the daily prediction and intraday predictions
      chart.series[3].setData(graph["intraday_predictionend"]); //same with this. maybe null.
    }
    //reset these arrays after using the setdata. not sure why this is necessary.
    graph["intraday_prediction"] = IntradayPredictions(graph["prediction"], undefined)[0]; //the 0 says to return only the first element of the returned value, which is 
    graph["daily_prediction"] = DailyPredictions(graph["prediction"], undefined)[0]; //the extra array of 0s is there for the prediction ids processor, which i
    graph["intraday_predictionend"] = IntradayPredictions(graph["predictionend"], undefined)[0];
    graph["daily_predictionend"] = DailyPredictions(graph["predictionend"], undefined)[0];

  }



  //duplicate.
  function BestRange (endTime) {
    for (var value in rangeHash) { //loop through the values of the rangehash - 1d, 5d, 1m ect..
      if (endTime < rangeHash[value]["xMax"]) { //if the endTime is less than the x max of the range, then its in range.
        return value; //return that value, ie, the button name - "1d", "5d" ect.
      }
    }
  }
}

//holds functions that are utilized across graphs.

var graphMediator = (function() {

  var components = {}

  //PUBLIC

  var addComponents = function(name, component) {
    components[name] = component;
  };

  var defaultProcessor = function() {
    var dailyLines = { //dailyLines is a component that contains the daily graph lines.
      dailyPrices: {lineArray:components.defaults.data.daily_prices,index:0}
    };

    var intradayLines = { //intradaylines is a component that contains the intraday graph lines.
      intradayPrices: {lineArray:components.defaults.data.intraday_prices, index:0}
    };

    addComponents('dailyLines', dailyLines); //this creates a component called dailyLines.
    addComponents('intradayLines', intradayLines); //this creates a component called intradayLines.
  
    createDateLine("dailyLines"); //adds the forward date array to the dailyLines component.
    createDateLine("intradayLines");  //adds the forward date array to the intradayLines component.
  
  };

  //this function is executed to run all functions that are dependent on whether or not the frame is in the 1d,5d vs 1m,3m,6m,1Yr ect.
  var frameDependents = function(graph) {

    var options = {
      stockGraph: {
        daily: function() {
          setSeries("dailyLines"),
          setHover("dailyPrices")
        },
        intraday: function() {
          setSeries("intradayLines"),
          setHover("intradayPrices")
        }
      }
    };

    if (components.currentFrame.timeFrame === "1D" || components.currentFrame.timeFrame === "5D") {
      options[graph]["intraday"]();
    }
    else {
      options[graph]["daily"]();
    }
  };

  //setSeries sets the series' defined in the daily and Intraday Line components.
  var setSeries = function(component) {
    for (var key in components[component]) {
      if (components[component].hasOwnProperty(key)) {
        var lineData = components[component][key].lineArray;
        var chart = components.defaults.chart;
        var seriesIndex = components[component][key].index;
        chart.series[seriesIndex].setData(lineData);
      }
    }
  };

  var setRange = function() { //sets the ranges of the graph based on the button in the currentRange component.
    var chart = components.defaults.chart
    var button = components.currentFrame.timeFrame;
    var frameHash = components.currentFrame.framesHash[button]
    chart.yAxis[0].setExtremes(frameHash.yMin, frameHash.yMax); //set y min and y max values
    chart.xAxis[0].setExtremes(frameHash.xMin, frameHash.xMax); //set x min and x max values
    console.log(frameHash);
  };

  //sets the on-hover respones for each graph line.
  var setHover = function(line) {
    var options = {};
    options["dailyPrices"] = {
      ajaxUrl:"/stockprices/hover_daily/",
      seriesIndex:0
    };

    options["intradayPrices"] = {
      ajaxUrl:"/stockprices/hover_intraday/",
      seriesIndex:0
    };

    var ajaxUrl = options[line].ajaxUrl;
    var seriesIndex = options[line].seriesIndex;
    
    components.defaults.chart.series[seriesIndex].update({ //update the options of the specified series.
      point: {
        events: {
          mouseOver: function(e) {
            $.ajax({
              url: ajaxUrl+this.id+"/", //pass the id to the ajaxURL
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
        }
      }
    });
  };

  var framesHash = function(graphType) { //the rangeHash is an array of buttons with the button name as the key and the value being an object of x and y mins and max.
    
    var buttonMin; //used to track the min price of the daily or intraday price array to use to set a max and min values.
    var buttonMax;

    var options = {
      limitTypeCbs: {
        min: function(lineArray) { 
          var newMin = lineArray.reduce(function (min, obj) {  //this reduce function needs to get the lowest price from the array.
            return obj.y < min ? obj.y : min; //if obj[1] (price) is less than the min, return obj[1], otherwise return min. 
          }, Infinity);
          buttonMin = newMin; //buttonMin is set here to be used in the next function when it gets called next.
          return newMin;
        }, //infinity is the value of the first min.
        limMin: function(lineArray) {
          var newMin = Infinity;
          for (var i = 0; i<lineArray.length; i++) {
            if (lineArray[i].y < newMin) {
              if (lineArray[i].y > buttonMin * 0.5) { //the min is 50% of the graph min price. The buttonMin is set in the min function.
                newMin = lineArray[i].y;
              }
            }
          };
          return newMin;
        },
        noLimMin: function(lineArray) {
          var newMin = Infinity;
          for (var i=0; i<lineArray.length; i++) {  
            if (lineArray[i].y < newMin) {
              newMin = lineArray[i].y;
            }
          };
          return newMin;
        },
        max: function(lineArray) {
          var max = lineArray.reduce(function (max, obj) {
            return obj.y > max ? obj.y : max;
          }, 0);
          buttonMax = max;
          return max;
        },
        limMax: function(lineArray) {
          var newMax = 0;
          for (i=0; i<lineArray.length; i++) {
            if (lineArray[i].y > newMax) {
              if (lineArray[i].y < buttonMax * 1.5) {
                newMax = lineArray[i].y;
              }
            }
          }
        },
        noLimMax: function(lineArray) {
          var newMax = 0;
          for (i=0; i<lineArray.length; i++) {
            if (lineArray[i].y > newMax) {
              newMax = lineArray[i].y;
            }
          }
        }
      },
      timeIntervals: {
        intraday: {
          tInterval: 60*5*1000,
          tLength: 6.5*3600*1000
        },
        daily: {
          tInterval: 24*3600*1000,
          tLength: 24*3600*1000
        }
      },
      extremes: {
        min: {
          cb: "minCb",
          comparisonCb: function(limit, new_limit) {
            if (limit === undefined) {
              return new_limit;
            }
            else if (new_limit < limit) {
              return new_limit;
            }
            else {
              return limit;
            }
          },
          bufferMaker: function(limit) {
            return limit - (buttonMin-limit)*0.05; 
          }
        },
        max : {
          cb: "maxCb",
          comparisonCb: function(limit, new_limit) {
            if (limit === undefined) {
              return new_limit;
            }
            else if (new_limit > limit) {
              return new_limit;
            }
            else {
              return limit;
            }
          },
          bufferMaker: function(limit) {
            return limit + (limit - buttonMax) * 0.05; //buttonmax will either be equal to or greater than the limit.
          }
        }
      },
      stockGraph: function() { //this is a function so that it will only execute when called. These lines won't exist for every graph.
        return {
          daily: {
            limitLines: [
              {
                line: components.dailyLines.dailyPrices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.dailyLines.dailyPredictions.lineArray,
                minCb: "limMin",
                maxCb: "limMax"
              },
              {
                line: components.dailyLines.dailyMyPrediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],
            startPoint: components.dailyLines.dailyPrices.lineArray.last().x
          },
          intraday: {
            limitLines: [
              {
                line: components.intradayLines.intradayPrices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.intradayLines.intradayPredictions.lineArray,
                minCb: "limMin",
                maxCb: "limMax"
              },
              {
                line: components.intradayLines.intradayMyPrediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],
            startPoint: components.intradayLines.intradayPrices.lineArray.last().x
          },
          buttons: [
            {name:"1D", beforeDays:1, afterDays:0.5, timeType:"intraday"},
            {name:"5D", beforeDays:5, afterDays:2.5, timeType:"intraday"},
            {name:"1M", beforeDays:20, afterDays:10, timeType:"daily"},
            {name:"3M", beforeDays:60, afterDays:30, timeType:"daily"},
            {name:"6M", beforeDays:120, afterDays:60, timeType:"daily"},
            {name:"1Yr", beforeDays:240, afterDays:120, timeType:"daily"},
            {name:"5Yr", beforeDays:1200, afterDays:600, timeType:"daily"}
          ]
        }
      }
    };

    var limitedArray = function(graphArray, xMin, xMax) { //this reduces the full array to an array of points between 2 dates.
      var returnArray = [];
      returnArray = graphArray.select(function(point) {
        if (point.x >= xMin && point.x <= xMax){
          return point;
        }
      });
      return returnArray;
    };

    var xLimit = function(intervalDirection, startPoint, timeWindow, timeType) { //startPoint is exepcted to be in graphtime.

      var times = options["timeIntervals"][timeType];

      var timeLength = times.tLength * timeWindow; //calculate the total time to iterate over.
      var i=0;
      iterations = timeLength/times.tInterval; //calculate number of iterations
      while (i<=iterations) {
        var time_to_check = (startPoint + i*times.tInterval*intervalDirection);
        if (!time_to_check.validStockTime()) { //validstocktime function expects a graph_time and returns true or false.
          iterations += 1; //if this time point is invalid, increase the number of iterations to do.
        }
        i+=1; //increase i everytime.
      }
      endPoint = startPoint + times.tInterval*iterations*intervalDirection;
      return endPoint;
    }

    var yLimit = function (graphType, timeType, xMin, xMax, limitType) {

      var fullArrays = options[graphType]()[timeType].limitLines; //returns the data arrays above for the target graph and time type.

      var limit; //this is the limit that will be returned from this function.

      fullArrays.forEach(function(element, index, array) { //for each array, get a ymin, and return it and check it.
        var limArr = limitedArray(element.line, xMin, xMax); //each array is limitted to just the relevant time frame.
        
        var cbType = options.extremes[limitType].cb; //returns a string called 'minCb' or 'maxCb' to get the Callback function name.
        var cbName = element[cbType]; //the callback is retrieved from the options hash via the graphType option, then the timeType (which is passed in through the function.) then it accesses the min or max callback using the 'extreme' setting from the options again.
        var cb = options.limitTypeCbs[cbName]; 
        var comparisonCb = options.extremes[limitType].comparisonCb;
        var newLimit = cb(element.line); //the callback should take array as an argument and return a limit.

        limit = comparisonCb(limit, newLimit); //returns either the old limit or new limit depending on limitype.
      });
      var pLimit = options.extremes[limitType].bufferMaker(limit); //add an extra 5% to the limit so that the prediction is not on the border.
      return pLimit;
    };


    var graphProcessor = function(graphType) { //receives the stockGraph or predictionGraph string. The options object outside this function is accessed for option settings.

      var processorOptions = options[graphType]();
      var frameHash = {};
      //run this when the xMin, ect functions are created and then this delivers the completed object.
      processorOptions.buttons.forEach(function(element, index, array) {
        var sP = processorOptions[element.timeType].startPoint;
        var xMin = xLimit(-1, sP, element.beforeDays, element.timeType);
        var xMax = xLimit(1, sP, element.afterDays, element.timeType);

        frameHash[element.name] = {
          xMin: xMin,
          xMax: xMax,
          yMin: yLimit(graphType, element.timeType, xMin, xMax, "min"),
          yMax: yLimit(graphType, element.timeType, xMin, xMax, "max")
        };
      });
      return frameHash;
    }

    return graphProcessor(graphType); //returns the rangeHash of buttons.

  };

  var createPredictionLine = function(line) {

    var dailyProcessor = function(gT) {
      var dayStr = gT.gmtString().dayString() + " 00:00:00 GMT"; //convert the graphtime to a gmt string, then convert that to the day string, and then add on 00:00:00 to round to the beginning of the day.
      var new_g_time = dayStr.graphTime() + gT.offsetTime() + 20*3600*1000; //get the graphtime for the start of the day add the offset time, and 20 hours to get to EOD at either 20 or 21 hours depending on DST.
      return new_g_time;
    };

    var intradayProcessor = function(gT) {
      var coeff = 1000 * 60 * 5;
      var rounded = Math.round(gT / coeff) * coeff; //get the rounded time.
      return rounded;
    };

    var options = {
      dailyPredictions: {
        cb: dailyProcessor,
        component: "dailyLines",
        predictions: components.defaults.data.predictions,
        index: 2
      },
      intradayPredictions: {
        cb: intradayProcessor,
        component: "intradayLines",
        predictions: components.defaults.data.predictions,
        index: 2
      },
      dailyMyPrediction: {
        cb:dailyProcessor,
        component: "dailyLines",
        predictions: components.defaults.data.my_prediction,
        index: 3
      },
      intradayMyPrediction: {
        cb:intradayProcessor,
        component: "intradayLines",
        predictions: components.defaults.data.my_prediction,
        index: 3
      }
    };

    var predictions = options[line].predictions;

    var predictionsArray = [];

    for(var i=0; i < predictions.length; i++ ) {
      var timeCompare = options[line].cb(predictions[i].x);
      if (predictionsArray.length === 0) { //if there are no predictions in the array, then add the first prediction.
        predictionsArray.push({"id":predictions[i].id, "x":timeCompare, "y":predictions[i].y})
      }
      else if (timeCompare !== predictionsArray.last().x) { //if this date is not the same as the last one, then add it.
        predictionsArray.push({"id":predictions[i].id, "x":timeCompare, "y":predictions[i].y})
      }
    }
    if (predictionsArray.length !== 0) {
      components[options[line].component][line] = {lineArray:predictionsArray, index:options[line].index}; //adds a new line to the specified component.
    }
  };

//   PRIVATE

  var createDateLine = function(line) {
    var options = {
      dailyLines: {
        startTime: components.defaults.data.intraday_prices.last().x, //this gets the last graphtime from the intradayprices array.
        iterations: 234, //this is 3 days forward. (6.5 * 3 * 60/5)
        interval: 5*60*1000,
        component: "intradayLines",
        index: 1 //the index is 1 because it is the second graphLine in the chart.
      },
      intradayLines: {
        startTime: components.defaults.data.daily_prices.last().x, //this gets the last graphtime from the dailyprices array.
        iterations: 780, //this is 3 years forward. (260*3)
        interval: 24*3600*1000, //interval of 1 day
        component: "dailyLines",
        index: 1 //the index is 1 because it is the second graphLine in the chart.
      }
    };

    var settings = options[line];

    var forwardArray = [];
    var i = 0;
    var iterations = settings.iterations;
    while (i<=iterations) {
      var timeSpot = settings.startTime + i*settings.interval;
      if (timeSpot.validStockTime()) {
        forwardArray.push({"x":timeSpot, "y":null});
      }
      else {
        iterations += 1;
      }
      i += 1;
    }
    components[settings.component][line] = {lineArray:forwardArray, index:settings.index} //this adds a new line to the dailyLines or intradayLines component.
  };

  return {
    addComponents: addComponents,
    setSeries: setSeries,
    defaultProcessor: defaultProcessor,
    setHover: setHover,
    frameDependents: frameDependents,
    createPredictionLine: createPredictionLine,
    framesHash: framesHash,
    setRange: setRange
  }
})();

function StockGraph(stockGraph, chart) {
  //StockGraphButtons sets the ranges based on 4 settings: intradayprices, dailyprices, predictions, and my_prediction.
  //All of these will come from the API.
  var graphSettings = {intradayPrices: stockGraph["intraday_prices"], dailyPrices:stockGraph["daily_prices"], predictions:stockGraph["predictions"], myPrediction:stockGraph["my_prediction"]}; //set the graph limits based on predictions and my prediction
  var rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d

  this.startChart = function() { //set the initial values when the graph prediction is null.

    //create these 2 graph arrays using the graph arrays from the server.
    //stockGraph["daily_forward_prices"] = DailyForwardPrices(stockGraph["daily_prices"].last()[0]); //create this array using js function.
    //stockGraph["intraday_forward_prices"] = IntradayForwardPrices(stockGraph["intraday_prices"].last()[0]); //create this array using js function.
    



    // var activeDailyPredictions = DailyPredictions(stockGraph["predictions"], stockGraph["prediction_ids"]) //Dailypredictions returns just 1 prediction for each day, and the corresponding prediction id array.
    // stockGraph["daily_predictions"] = activeDailyPredictions[0];
    // stockGraph["daily_prediction_ids"] = activeDailyPredictions[1];

    // //possibly have some intermediate variable here like above.
    // var activeIntradayPredictions = IntradayPredictions(stockGraph["predictions"], stockGraph["prediction_ids"]);
    // stockGraph["intraday_predictions"] = activeIntradayPredictions[0];
    // stockGraph["intraday_prediction_ids"] = activeIntradayPredictions[1];

    if (stockGraph["my_prediction"][0][0] === null) {
      var bestButton = "1M"; //sets the x axis ranges to the 1m ranges
    }
    else {
      var endTime = stockGraph["my_prediction"].last()[0]; //use the endTime of the users own prediction to get the best range.
      var bestButton = BestRange(endTime);
    }

    setPredictions(stockGraph); //create the daily and intraday prediction arrays, and the corresponding prediction id arrays.

    if (bestButton == "1D" || bestButton == "5D") { //make the current range different from the bestbutton.
      currentRange["buttonType"] = "1M";
    }
    else {
      currentRange["buttonType"] = "1D";
    }

    setMyPrediction(stockGraph["my_prediction"]); //set the daily and intraday my_prediction graph arrays based on my_prediction.
    //removeOverlapping(bestButton); //must be used after setMyPrediction.removes predictions overlapping with my_prediction.

    //stockChart.series[0].setData(stockGraph["daily_prices"]);
    //setSeries(bestButton, stockGraph);
    setRange(bestButton); //always setRange after the setSeries, so the set series can tell if the range has changed. currentRange gets updated in the setRange.
  
    $('*[data-button-type="'+currentRange["buttonType"]+'"]').switchClass("timeframe-item", "timeframe-item-selected");
  };

  this.buttonClick = function() {
    var buttonType = $(this).data("button-type");
    setSeries(buttonType, stockGraph); //always set series before range. Resets all series arrays if there is a button type change.
    setRange(buttonType);

    //change the on-hover states based on what has been clicked.
    $(".timeframe-item-selected").switchClass("timeframe-item-selected", "timeframe-item")
    $(this).switchClass("timeframe-item", "timeframe-item-selected");
  };

  this.inputPrediction = function(endTime, endPrice, predictionId) {

    //reset these two values...
    stockGraph["my_prediction"] = ([[endTime, endPrice]]); //reset the 'my_prediciton' array in graph. endtTime and endPrice are sent by the prediction input ajax function.
    
    stockGraph["my_prediction_id"] = [predictionId];

    var bestButton = BestRange(endTime); //find the best button range to use based on the end day of the prediction.

    setMyPrediction(stockGraph["my_prediction"]); //set the intraday_my_prediction, daily_my_prediction.
    removeOverlapping() //Nullify overlapping predictions

    updateMyPrediction(bestButton); //update just the myprediction on the graph. If there is a change in button type, the setSeries function will still update all of the other arrays.
    
    graphSettings = {intradayPrices: stockGraph["intraday_prices"], dailyPrices:stockGraph["daily_prices"], predictions:stockGraph["predictions"], myPrediction:stockGraph["my_prediction"]}; //set the graph limits based on predictions and my prediction. Graph is reset based on new prediction range.
    rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d,1m,3m,6m,1yr,5yr

    setSeries(bestButton, stockGraph); //setSeries sets all of the graph arrays based on the graph object. Always comes before setRange.
    setRange(bestButton); //setRange utilizes the rangeHash. updates the currentRange.


    //this needs to be reset only once the daily prediction rounder function is set.
    //graph["daily_my_prediction"] = DailyPredictions(graph["my_prediction"], graph["daily_prices"].last()[0]); //reset the value of daily_my_prediction based on the new my_prediction value.
  };

  this.removePrediction = function() {
    stockGraph["my_prediction"] = [[null,null]];

    chart.series[3].setData(stockGraph["my_prediction"]); //instead of resetting all series', just reset this one.

    var graphSettings = {intradayPrices: stockGraph["intraday_prices"], dailyPrices:stockGraph["daily_prices"], predictions:stockGraph["predictions"], myPrediction:stockGraph["my_prediction"]};
    rangeHash = new StockGraphButtons(graphSettings); //recreate the original ranges based on the data arrays.
    
    var buttonType = currentRange["buttonType"];
    setRange(buttonType); //the buttonType doesnt change, but the ranges of the current range may change.
    //no need to setSeries. The only series update is taken care of.
    setMyPrediction(stockGraph["my_prediction"]); //set the my prediction arrays based on the new graph["my_prediction"] variable.

  }

  function setPredictions(theGraph) { //update the prediction arrays to contain the correctly rounded times and remove same-time predictions.
    var activeDailyPredictions = DailyPredictions(theGraph["predictions"], theGraph["prediction_ids"]) //Dailypredictions returns just 1 prediction for each day, and the corresponding prediction id array.
    stockGraph["daily_predictions"] = activeDailyPredictions[0];
    stockGraph["daily_prediction_ids"] = activeDailyPredictions[1];

    //possibly have some intermediate variable here like above.
    var activeIntradayPredictions = IntradayPredictions(theGraph["predictions"], theGraph["prediction_ids"]);
    stockGraph["intraday_predictions"] = activeIntradayPredictions[0];
    stockGraph["intraday_prediction_ids"] = activeIntradayPredictions[1];
  }

  function setMyPrediction (myPrediction) {
    //update the viewable my_prediction arrays based on the actual my_prediction.
    stockGraph["daily_my_prediction"] = DailyMyPrediction(myPrediction);
    stockGraph["intraday_my_prediction"] = IntradayMyPrediction(myPrediction);
  }

  function removeOverlapping () { //not sure if this is still working.
    // var removedDaily = false;
    // var removedIntraday = false;
    for (var i=0; i<stockGraph["daily_predictions"].length;i++) {
      if (stockGraph["daily_predictions"][i].indexOf(stockGraph["daily_my_prediction"][0][0]) !== -1) {
        stockGraph["daily_predictions"].splice(i, 1); //removes the prediction from the array where it is the same as my_prediction.
        stockGraph["daily_prediction_ids"].splice(i, 1);
        //removedDaily = true;
      }
    }
    for (var i=0; i<stockGraph["intraday_predictions"].length; i++) {
      if (stockGraph["intraday_predictions"][i].indexOf(stockGraph["intraday_my_prediction"][0][0]) !== -1) {
        stockGraph["intraday_predictions"].splice(i, 1); //removes the prediction from the array where it is the same as my_prediction.
        stockGraph["intraday_prediction_ids"].splice(i, 1);
        //removedIntraday = true;
      }
    }
    // graph["intraday_predictions"] = 
    // if ((removedIntraday === true) && (button === "1d" || button === "5d")) {
    //   chart.series[2].setData(graph["intraday_predictions"]);
    // }
    // if ((removedDaily === true) && (button !== "1d" && button !== "5d")) {
    //   chart.series[2].setData(graph["daily_predictions"]);
    // }
  }

  //duplicate.
  function BestRange (endTime) {
    for (var value in rangeHash) { //loop through the values of the rangehash - 1d, 5d, 1m ect..
      if (endTime < rangeHash[value]["xMax"]) { //if the endTime is less than the x max of the range, then its in range.
        return value; //return that value, ie, the button name - "1d", "5d" ect.
      }
    }
  }

  function setSeries (button, theGraph) { //set the ranges based on the button input. Also set based on whether or not a prediction exists?
    
    //if (button === "1d" || button === "5d") {
    if ((button === "1D" || button === "5D") && (currentRange["buttonType"] !== "1D" && currentRange["buttonType"] !== "5D")) { //set intraday graph arrays
      //console.log(graph["daily_predictions"]);
      //var oops = graph["intraday_predictions"];
      //console.log(oops);
      //chart.series[2].setData(oops); //this may be null
      //// NO IDEA WHY THIS IS NECESSARY
        //var activeDailyPredictions = DailyPredictions(graph["predictions"], graph["prediction_ids"]) //Dailypredictions returns just 1 prediction for each day, and the corresponding prediction id array.
        //graph["daily_predictions"] = activeDailyPredictions[0];
      ///this probably needs to be reset as well.
        //setMyPrediction(graph["my_prediction"]); //set the daily and intraday my_prediction graph arrays based on my_prediction.
      //okokokokok

      //chart.series[0].setData(theGraph["intraday_prices"]);
      //chart.series[1].setData(theGraph["intraday_forward_prices"]);
      //chart.series[2].setData(theGraph["intraday_predictions"]);
      //chart.series[3].setData(theGraph["intraday_my_prediction"]); //this may be null

    }
    if ((button !== "1D" && button !== "5D") && (currentRange["buttonType"] === "1D" || currentRange["buttonType"] === "5D")) { //set daily graph
    //if (button !== "1d" && button !== "5d") {
      console.log(theGraph["daily_prices"]);
      //theGraph["daily_prices"] = [[1427981400000, 85],[1427981700000, 85]];
      //theGraph["daily_prices"] = [{"x":1427981400000, "y":85},{"x":1427981700000, "y":85}];
      console.log(theGraph["daily_prices"]);
      chart.series[0].setData(theGraph["daily_prices"]);
      //chart.series[1].setData(theGraph["daily_forward_prices"]);
      //chart.series[2].setData(theGraph["daily_predictions"]);
      //chart.series[3].setData(theGraph["daily_my_prediction"]);
    }
    setPredictions(stockGraph); //reset the predictions array. They get unset from running these setData functions, not sure why.
    setMyPrediction(stockGraph["my_prediction"]); //set the daily and intraday my_prediction graph arrays based on my_prediction.
    
  }

  function updateMyPrediction (button) {
    if (currentRange["buttonType"] === "1D" || currentRange["buttonType"] === "5D") {
      chart.series[3].setData(stockGraph["intraday_my_prediction"]);
    }
    if (currentRange["buttonType"] !== "1D" && currentRange["buttonType"] !== "5D") {
      chart.series[3].setData(stockGraph["daily_my_prediction"]);
    }
  }

  //duplicate function.
  function setRange(button) { //sets the ranges of the graph based on a target button, 1d,5d,1m,3m,6m ect.
    chart.yAxis[0].setExtremes(rangeHash[button]["yMin"], rangeHash[button]["yMax"]); //set y min and y max values
    chart.xAxis[0].setExtremes(rangeHash[button]["xMin"], rangeHash[button]["xMax"]); //set x min and x max values
    currentRange = {rangeHash:rangeHash[button],buttonType:button};
  }
}



function Button(buttonSettings) {
  var beforeDays = buttonSettings["beforeDays"];
  var afterDays = buttonSettings["afterDays"];
  var settings = buttonSettings["settings"]; //contains 6 items: timeInterval, timeLength, startPoint, prices, predictions, myPrediction
 
  //intervalDirection is the direction to move from the start point.
  //startpoint is where to start counting from.
  //timeWindow is the total amount of time to look over. 5 days, 1 yr, ect.
  function EndPoint (intervalDirection, startPoint, timeWindow) { //startPoint is exepcted to be in graphtime.
    timeLength = settings.timeLength * timeWindow; //calculate the total time to iterate over.
    var i=0;
    iterations = timeLength/settings.timeInterval; //calculate number of iterations
    while (i<=iterations) {
      var time_to_check = (startPoint + i*settings.timeInterval*intervalDirection).utcTimeInt().utcTimeStr(); //convert the graphtime int to utc time int, then to utc time string for processing.
      //if (!time_to_check.validStockTime()) { //validstocktime function expects a string.
      //  iterations += 1; //if this time point is invalid, increase the number of iterations to do.
      //  console.log("startPoint:"+startPoint);
      //}
      i+=1; //increase i everytime.
    }
    endPoint = startPoint + settings.timeInterval*iterations*intervalDirection;
    return endPoint;
  }

  var startPoint = settings.startPoint;

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
  if (settings.predictions != undefined) { //for the predictiondetails graph, the predictions array is undefined.
    var limitedPredictions = limitedArray(settings.predictions); //The predictions that fall into the x axis time frame.
  }
  var limitedMyPrediction = limitedArray(settings.myPrediction); //myPrediction forces the ranges to include the end point.

  
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
