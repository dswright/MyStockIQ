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




//holds functions that are utilized across graphs.

var graphMediator = (function() {

  var components = {};

  //PUBLIC

  var addComponents = function(name, component) {
    components[name] = component;
  };

  var updateComponent = function(component, callback) {
    callback.call(components[component]);
  };

  var defaultProcessor = function() {
    var dailyLines = { //dailyLines is a component that contains the daily graph lines.
      prices: {lineArray:components.defaults.data.daily_prices,index:0},
      forward_dates: {lineArray:components.defaults.data.future_days,index:1}
    };

    var intradayLines = { //intradaylines is a component that contains the intraday graph lines.
      prices: {lineArray:components.defaults.data.intraday_prices,index:0},
      forward_dates: {lineArray:components.defaults.data.future_times,index:1}
    };

    addComponents('dailyLines', dailyLines); //this creates a component called dailyLines.
    addComponents('intradayLines', intradayLines); //this creates a component called intradayLines.
  
    // createDateLine("dailyLines"); //adds the forward date array to the dailyLines component.
    // createDateLine("intradayLines");  //adds the forward date array to the intradayLines component.    
  };

  //this function is executed to run all functions that are dependent on whether or not the frame is in the 1d,5d vs 1m,3m,6m,1Yr ect.
  var frameDependents = function(graph) {

    var options = {
      stockGraph: {
        daily: function() {
          setSeries("dailyLines");
          setHover("dailyPrices");
          setHover("dailyPredictions"); //not working yet.
          setHover("dailyMyPrediction"); //not working yet.
        },
        intraday: function() {
          setSeries("intradayLines");
          setHover("intradayPrices");
          setHover("intradayPredictions"); //not working yet.
          setHover("intradayMyPrediction"); //not working yet.
        }
      },
      predictionGraph: {
        daily: function() {
          setSeries("dailyLines");
          setHover("dailyPrices");
        },
        intraday: function() {
          setSeries("intradayLines");
          setHover("intradayPrices");
        }
      }
    };

    if (components.currentFrame.timeFrame === "1D" || components.currentFrame.timeFrame === "5D") {
      options[graph]["intraday"]();
    }
    else {
      options[graph]["daily"]();
    }

    $(".timeframe-item-selected").switchClass("timeframe-item-selected", "timeframe-item");
    $('*[data-button-type="'+components.currentFrame.timeFrame+'"]').switchClass("timeframe-item", "timeframe-item-selected");
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
  };

  //sets the on-hover respones for each graph line.
  var setHover = function(line) {
    var options = {
      dailyPrices: {
        ajaxUrl:"/stockprices/hover_daily/",
        seriesIndex:0
      },
      intradayPrices: {
        ajaxUrl:"/stockprices/hover_intraday/",
        seriesIndex:0
      },
      dailyPredictions: {
        ajaxUrl: "/predictions/hover_daily/",
        seriesIndex:2
      },
      intradayPredictions: {
        ajaxUrl: "predictions/hover_intraday/",
        seriesIndex:2
      },
      dailyMyPrediction: {
        ajaxUrl: "/predictions/hover_daily/",
        seriesIndex:3
      },
      intradayMyPrediction: {
        ajaxUrl: "/predictions/hover_intraday/",
        seriesIndex:3
      }
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

  var framesHash = function(graphType) { //the frameHash is an array of buttons with the button name as the key and the value being an object of x and y mins and max.
    
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
          return newMax
        },
        noLimMax: function(lineArray) {
          var newMax = 0;
          for (i=0; i<lineArray.length; i++) {
            if (lineArray[i].y > newMax) {
              newMax = lineArray[i].y;
            }
          }
          return newMax
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
                line: components.dailyLines.prices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.dailyLines.predictions.lineArray,
                minCb: "limMin",
                maxCb: "limMax"
              },
              {
                line: components.dailyLines.myPrediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],
            startPoint: components.dailyLines.prices.lineArray.last().x
          },
          intraday: {
            limitLines: [
              {
                line: components.intradayLines.prices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.intradayLines.predictions.lineArray,
                minCb: "limMin",
                maxCb: "limMax"
              },
              {
                line: components.intradayLines.myPrediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],
            startPoint: components.intradayLines.prices.lineArray.last().x
          },
          buttons: [
            {name:"1D", backInterval:78, forwardInterval:39, timeType:"intraday"}, //1 day back is 78 intervals (6.5*12)
            {name:"5D", backInterval:390, forwardInterval:195, timeType:"intraday"}, //5 days back is 78*5 intervals. 
            {name:"1M", backInterval:20, forwardInterval:10, timeType:"daily"}, 
            {name:"3M", backInterval:60, forwardInterval:30, timeType:"daily"},
            {name:"6M", backInterval:120, forwardInterval:60, timeType:"daily"},
            {name:"1Yr", backInterval:240, forwardInterval:120, timeType:"daily"},
            {name:"5Yr", backInterval:1200, forwardInterval:600, timeType:"daily"}
          ]
        }
      },
      predictionGraph: function() { //this is a function so that it will only execute when called. These lines won't exist for every graph.
        return {
          daily: {
            limitLines: [
              {
                line: components.dailyLines.prices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.dailyLines.prediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              },
              {
                line: components.dailyLines.predictionend.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],

            //startPoint: components.dailyLines.prices.lineArray.last().x
            startPoint: components.dailyLines.prediction.lineArray[0].x
          },
          intraday: {
            limitLines: [
              {
                line: components.intradayLines.prices.lineArray,
                minCb: "min",
                maxCb: "max"
              },
              {
                line: components.intradayLines.prediction.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              },
              {
                line: components.intradayLines.predictionend.lineArray,
                minCb: "noLimMin",
                maxCb: "noLimMax"
              }
            ],
            //startPoint: components.intradayLines.prices.lineArray.last().x
            startPoint: components.intradayLines.prediction.lineArray[0].x
          },
          buttons: [
            {name:"1D", backInterval:78, forwardInterval:39, timeType:"intraday"}, //1 day back is 78 intervals (6.5*12)
            {name:"5D", backInterval:390, forwardInterval:195, timeType:"intraday"}, //5 days back is 78*5 intervals. 
            {name:"1M", backInterval:20, forwardInterval:10, timeType:"daily"}, 
            {name:"3M", backInterval:60, forwardInterval:30, timeType:"daily"},
            {name:"6M", backInterval:120, forwardInterval:60, timeType:"daily"},
            {name:"1Yr", backInterval:240, forwardInterval:120, timeType:"daily"},
            {name:"5Yr", backInterval:1200, forwardInterval:600, timeType:"daily"}
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

    // var xLimit = function(intervalDirection, startPoint, timeWindow, timeType) { //startPoint is exepcted to be in graphtime.

    //   //just need the array, and the number of iterations to go down.


    //   // var times = options["timeIntervals"][timeType];

    //   // var timeLength = times.tLength * timeWindow; //calculate the total time to iterate over.
    //   // var i=0;
    //   // iterations = timeLength/times.tInterval; //calculate number of iterations
    //   // while (i<=iterations) {
    //   //   var time_to_check = (startPoint + i*times.tInterval*intervalDirection);
    //   //   if (!time_to_check.validStockTime()) { //validstocktime function expects a graph_time and returns true or false.
    //   //     iterations += 1; //if this time point is invalid, increase the number of iterations to do.
    //   //   }
    //   //   i+=1; //increase i everytime.
    //   // }
    //   // endPoint = startPoint + times.tInterval*iterations*intervalDirection;
    //   // return endPoint;
    // }

    var xLimit = function(timeType, intervals, intervalDirection, startPoint) {
      var options = {
        forward: {
          daily: function() { return components.defaults.data.future_days },
          intraday: function() { return components.defaults.data.future_times },
          processor: function(arr, intervals, startPoint) { //startpoint isnt actually used but it needs to be here anyway.
            return arr.splice(intervals,1);
          }
        },
        backward: {
          daily: function() { return components.defaults.data.daily_prices },
          intraday: function() { return components.defaults.data.intraday_prices },
          processor: function(arr, intervals, startPoint) {
            var arrTimes = arr.map(function(element) { return element.x; });
            var cutOff = arrTimes.indexOf(startPoint);
            var newArr = arr.slice(0, cutOff);
            var limit = newArr.splice(intervals*-1, 1);
            return limit;
          }
        }
      };

      var arr = options[intervalDirection][timeType]();

      var processor = options[intervalDirection]["processor"];
      var limit = processor(arr, intervals, startPoint);
      return limit[0].x;

      //for getting the forward looking date, slice off the array from the begginning:
    };

    var yLimit = function (graphType, timeType, xMin, xMax, limitType) {

      var fullArrays = options[graphType]()[timeType].limitLines; //returns the data arrays above for the target graph and time type.

      var limit; //this is the limit that will be returned from this function.

      fullArrays.forEach(function(element, index, array) { //for each array, get a ymin, and return it and check it.
        if (element.line != null) { //make sure the array is not set to null.
          var limArr = limitedArray(element.line, xMin, xMax); //each array is limitted to just the relevant time frame.
          var cbType = options.extremes[limitType].cb; //returns a string called 'minCb' or 'maxCb' to get the Callback function name.
          var cbName = element[cbType]; //the callback is retrieved from the options hash via the graphType option, then the timeType (which is passed in through the function.) then it accesses the min or max callback using the 'extreme' setting from the options again.
          var cb = options.limitTypeCbs[cbName]; 
          var comparisonCb = options.extremes[limitType].comparisonCb;
          var newLimit = cb(limArr); //the callback should take array as an argument and return a limit.
          limit = comparisonCb(limit, newLimit); //returns either the old limit or new limit depending on limitype.
        }
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
        //var xMin = xLimit(-1, sP, element.beforeDays, element.timeType);
        //var xMax = xLimit(1, sP, element.afterDays, element.timeType);

        var xMin = xLimit(element.timeType, element.backInterval, "backward", sP);
        var xMax = xLimit(element.timeType, element.forwardInterval, "forward", sP);

        frameHash[element.name] = {
          xMin: xMin,
          xMax: xMax,
          yMin: yLimit(graphType, element.timeType, xMin, xMax, "min"),
          yMax: yLimit(graphType, element.timeType, xMin, xMax, "max")
        };
      });
      return frameHash;
    };

    return graphProcessor(graphType); //returns the rangeHash of buttons.

  };

  var createPredictionLine = function(timeType, line) {

    var dailyProcessor = function(gT) {
      var dayStr = gT.gmtString().dayString() + " 00:00:00 GMT"; //convert the graphtime to a gmt string, then convert that to the day string, and then add on 00:00:00 to round to the beginning of the day.
      var new_g_time = dayStr.graphTime() + (21*3600*1000 - gT.offsetTime()); //get the graphtime for the start of the day add the offset time, and 20 hours to get to EOD at either 20 or 21 hours depending on DST.
      return new_g_time;
    };

    var intradayProcessor = function(gT) {
      var coeff = 1000 * 60 * 5;
      var rounded = Math.round(gT / coeff) * coeff; //get the rounded time.
      return rounded;
    };

    var options = {
      daily: {
        cb: dailyProcessor,
        component: "dailyLines"
      },
      intraday: {
        cb: intradayProcessor,
        component: "intradayLines"
      },
      lines: {
        //stockgraph prediction lines.
        predictions: function() {
          return {
            line: components.defaults.data.predictions,
            index: 2
          }
        },
        myPrediction: function() {
          return { 
            line: components.defaults.data.my_prediction,
            index:3
          }
        },
        prediction: function() {
          return {
            line: components.defaults.data.prediction,
            index:2
          }
        },
        predictionend: function() {
          return {
            line: components.defaults.data.predictionend,
            index:3
          }
        }
      }
    };

    var predictionLine = options.lines[line]();
    var predictions = predictionLine.line;

    var predictionsArray = [];

    for(var i=0; i < predictions.length; i++ ) {
      var timeCompare = options[timeType].cb(predictions[i].x);
      if (predictionsArray.length === 0) { //if there are no predictions in the array, then add the first prediction.
        predictionsArray.push({"id":predictions[i].id, "x":timeCompare, "y":predictions[i].y, "marker":predictions[i].marker})
      }
      else if (timeCompare !== predictionsArray.last().x) { //if this date is not the same as the last one, then add it.
        predictionsArray.push({"id":predictions[i].id, "x":timeCompare, "y":predictions[i].y, "marker":predictions[i].marker})
      }
    }

    var componentType = options[timeType].component;
    if (predictionsArray.length !== 0) {
      components[componentType][line] = {lineArray:predictionsArray, index:predictionLine.index}; //adds a new line to the specified component.
    }
    else {
      components[componentType][line] = {lineArray:null, index:predictionLine.index};
    }
  };

  var bestRange = function(endType) { 
    var options = {
      myPrediction: function() {
        return components.defaults.data.my_prediction[0];
      },
      prediction: function() {
        return components.defaults.data.prediction[1];
      }
    };

    var endTime = options[endType](); //endTime is a hash of index, x, and y values.

    if (endTime === undefined) { //the endtime will be undefined when the my_prediction array is empty.
      return "1Yr";

    }
    for (var value in components.currentFrame.framesHash) { //loop through the values of the frameHash - 1d, 5d, 1m ect..
      if (endTime.x < components.currentFrame.framesHash[value]["xMax"]) { //if the endTime is less than the x max of the range, then its in range.
        return value; //return that value, ie, the button name - "1d", "5d" ect.
      }
    }
  }

  var removeOverlapping = function(timeType, lineType) { //not sure if this is still working.
    var options = {
      intraday: {
        myPrediction: {
          mainLine: components.intradayLines.predictions, 
          filterPoint: components.intradayLines.myPrediction[0]
        }
      },
      daily: {
        myPrediction: {
          mainLine: components.dailyLines.predictions,
          filterPoint: components.dailyLines.myPrediction[0]
        }
      }
    };
    var mainLine = options[timeType][lineType];
    var filterPoint = options[timeType][lineType];

    if (filterPoint !== undefined) {
      for (var i=0; i<mainLine.length;i++) {
        if (mainLine[i].indexOf(filterPoint) !== -1) {
          largeArray.splice(i, 1);
        }
      }
    }
  }


//   PRIVATE
  var createDateLine = function(line) {
    var options = {
      intradayLines: {
        startTime: components.defaults.data.intraday_prices.last().x, //this gets the last graphtime from the intradayprices array.
        iterations: 234, 
        interval: 5*60*1000,
        component: "intradayLines",
        index: 1 //the index is 1 because it is the second graphLine in the chart.
      },
      dailyLines: {
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
    components[settings.component]["forward_dates"] = {lineArray:forwardArray, index:settings.index} //this adds a new line to the dailyLines or intradayLines component.
  };

  return {
    addComponents: addComponents,
    updateComponent: updateComponent,
    setSeries: setSeries,
    defaultProcessor: defaultProcessor,
    setHover: setHover,
    frameDependents: frameDependents,
    createPredictionLine: createPredictionLine,
    framesHash: framesHash,
    setRange: setRange,
    bestRange: bestRange,
    removeOverlapping: removeOverlapping
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
}