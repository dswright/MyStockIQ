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
  //StockGraphButtons sets the ranges based on 4 settings: intradayprices, dailyprices, predictions, and my_prediction.
  //All of these will come from the API.
  var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:graph["my_prediction"]}; //set the graph limits based on predictions and my prediction
  var rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d
  var currentRange;
  var graph = graph;


  this.startChart = function() { //set the initial values when the graph prediction is null.

    //create these 2 graph arrays using the graph arrays from the server.
    graph["daily_forward_prices"] = DailyForwardPrices(graph["daily_prices"].last()[0]); //create this array using js function.
    graph["intraday_forward_prices"] = IntradayForwardPrices(graph["intraday_prices"].last()[0]); //create this array using js function.

    //need to do the same thing for the my_prediction here.. How to handle the live prediction ids?
    //Should i be worried about this at the moment? Seems like an improvement. Yeah, I'll hold off. Continue migrating shit over for now.
    //for now, intraday prediction will just overlap, and not have scrollover details in the header. That's what needs to change.


    if (graph["my_prediction"][0][0] === null) {
      var bestButton = "1m"; //sets the x axis ranges to the 1m ranges
    }
    else {
      var endTime = graph["my_prediction"].last()[0]; //use the endTime of the users own prediction to get the best range.
      var bestButton = BestRange(endTime);
    }

    setPredictions(); //set the prediction arrays and prediction id arrays based on 
    setMyPrediction(graph["my_prediction"]); //set the my prediction arrays based on the graph["my_prediction"] variable.
    updatePredictionIds(bestButton); //set which prediction_ids array to use based on the current active button.

    setSeries(bestButton);
    setRange(bestButton);
  };

  this.buttonClick = function() {
    console.log(graph);
    var buttonType = $(this).data("button-type");
    setSeries(buttonType);
    setRange(buttonType);
    updatePredictionIds(buttonType);
  };

  this.inputPrediction = function(endTime, endPrice) {

    //reset these two values...
    graph["my_prediction"] = ([[endTime, endPrice]]); //reset the 'my_prediciton' array in graph. endtTime and endPrice are sent by the prediction input ajax function.
    
    //pass in the predictions and the prediction ids to be redone...
    //Are these both just 1 big array? No. Different arrays, but they will need to reference each other to avoid overlapping..?

    //DailyPredictions(); //this will be neessary once I create the daily_my_prediction.
      //update the graph["daily_my_prediction"] to be used in the monthly graph.
      //update the graph["live_predictions"] with my_prediction, so that the monthly and daily predictions id arrays are correctly reflecting the predictions in the grpah.

    var bestButton = BestRange(endTime); //find the best button range to use based on the end day of the prediction.

    //this should reset the graph settings and rangeHash for any remaining functions that are run.
    //this needs to be reset because my_prediction has been updated.
    //the graph settings should use adjusted arrays, not the true data arrays).
    
    setMyPrediction(graph["my_prediction"]); //set the my prediction arrays based on the new graph["my_prediction"] variable.
    updatePredictionIds(bestButton); //set which prediction_ids array to use based on the current active button.

    graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:graph["my_prediction"]}; //set the graph limits based on predictions and my prediction. Graph is reset based on new prediction range.
    rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d,1m,3m,6m,1yr,5yr

    setRange(bestButton); //setRange utilizes the rangeHash.
    setSeries(bestButton); //set series uses upgraded


    //this needs to be reset only once the daily prediction rounder function is set.
    //graph["daily_my_prediction"] = DailyPredictions(graph["my_prediction"], graph["daily_prices"].last()[0]); //reset the value of daily_my_prediction based on the new my_prediction value.
  }

  this.removePrediction = function() {
    graph["my_prediction"] = [[null,null]];

    chart.series[3].setData(graph["my_prediction"]); //instead of resetting all series', just reset this one. May change this to full series reset later.

    var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:graph["my_prediction"]};
    rangeHash = new StockGraphButtons(graphSettings); //recreate the original ranges based on the data arrays.
    
    var buttonType = currentRange["buttonType"];
    setRange(buttonType);
    setMyPrediction(graph["my_prediction"]); //set the my prediction arrays based on the new graph["my_prediction"] variable.

  }

  function setPredictions() { //update the prediction arrays to contain the correctly rounded times and remove same-time predictions.
    var activeDailyPredictions = DailyPredictions(graph["predictions"], graph["prediction_ids"]) //Dailypredictions returns just 1 prediction for each day, and the corresponding prediction id array.
    graph["daily_predictions"] = activeDailyPredictions[0];
    graph["daily_prediction_ids"] = activeDailyPredictions[1];

    //possibly have some intermediate variable here like above.
    var activeIntradayPredictions = IntradayPredictions(graph["predictions"], graph["prediction_ids"]);
    graph["intraday_predictions"] = activeIntradayPredictions[0];
    graph["intraday_prediction_ids"] = activeIntradayPredictions[1];
  }

  function setMyPrediction (myPrediction) {
    //update the viewable my_prediction arrays based on the actual my_prediction.
    graph["daily_my_prediction"] = DailyMyPrediction(myPrediction);
    graph["intraday_my_prediction"] = IntradayMyPrediction(myPrediction);

    for (var i=0; i<graph["daily_predictions"];i++) {
      if (graph["daily_predictions"][i].indexOf(graph["daily_my_prediction"][0][0]) !== -1) {
        graph["daily_predictions"][i] = [null, null];
      }
    }
    for (var i=0; i<graph["intraday_predictions"];i++) {
      if (graph["intraday_predictions"][i].indexOf(graph["intraday_my_prediction"][0][0]) !== -1) {
        graph["intraday_predictions"][i] = [null, null];
      }
    }
  }

  function updatePredictionIds(buttonType) {
    if (buttonType === "1d" || buttonType === "5d") {
      graph["active_prediction_ids"] = graph["intraday_prediction_ids"];
    }
    else {
      graph["active_prediction_ids"] = graph["daily_prediction_ids"];
    }
    //my_prediction_id does not need to be set here, the tooltip functions calls the graph["my_prediction_id"] directly.
  }


  function BestRange (endTime) {
    for (var value in rangeHash) { //loop through the values of the rangehash - 1d, 5d, 1m ect..
      if (endTime < rangeHash[value]["xMax"]) { //if the endTime is less than the x max of the range, then its in range.
        return value; //return that value, ie, the button name - "1d", "5d" ect.
      }
    }
  }

  function setSeries (button) { //set the ranges based on the button input. Also set based on whether or not a prediction exists?
    if (button === "1d" || button === "5d") { //set intraday graph arrays
      chart.series[0].setData(graph["intraday_prices"]);
      chart.series[1].setData(graph["intraday_forward_prices"]);
      chart.series[2].setData(graph["intraday_predictions"]); //this may be null
      chart.series[3].setData(graph["intraday_my_prediction"]); //this may be null
    }
    else { //set daily graph
      chart.series[0].setData(graph["daily_prices"]);
      chart.series[1].setData(graph["daily_forward_prices"]);
      chart.series[2].setData(graph["daily_predictions"]);
      chart.series[3].setData(graph["daily_my_prediction"]);
    }
  }

  function setRange(button) { //sets the ranges of the graph based on a target button, 1d,5d,1m,3m,6m ect.
    chart.yAxis[0].setExtremes(rangeHash[button]["yMin"], rangeHash[button]["yMax"]); //set y min and y max values
    chart.xAxis[0].setExtremes(rangeHash[button]["xMin"], rangeHash[button]["xMax"]); //set x min and x max values
    currentRange = {rangeHash:rangeHash[button],buttonType:button};
  }

  function IntradayPredictions (predictions, predictionIds) {
    var predictionsArray = [];
    var predictionIdsArray = [];
    for (var i=0; i< predictions.length; i++ ) {
      var dateStamp = predictions[i][0].utcTimeInt().utcTimeStr().utcTime();
      var coeff = 1000 * 60 * 5;
      var rounded = new Date(Math.round(dateStamp.getTime() / coeff) * coeff); //get the rounded time.
      var graphTime = rounded.utcTimeInt().graphTimeInt();

      if (predictionsArray.last() === undefined) {
        predictionsArray.push([graphTime, predictions[i][1]]);
        predictionIdsArray.push(predictionIds[i]);
      }
      else if (predictionsArray.last()[0] !== rounded ) {
        predictionsArray.push([graphTime, predictions[i][1]]);
        predictionIdsArray.push(predictionIds[i]);
      }
    }
    return [predictionsArray, predictionIdsArray];
  }

  function IntradayMyPrediction (myPrediction) {
    if (myPrediction[0][0] !== null) {
      var dateStamp = myPrediction[0][0].utcTimeInt().utcTimeStr().utcTime();
      var coeff = 1000 * 60 * 5;
      var rounded = new Date(Math.round(dateStamp.getTime() / coeff) * coeff); //get the rounded time.
      var graphTime = rounded.utcTimeInt().graphTimeInt();
      return [[graphTime, myPrediction[0][1]]];
    }
    else {
      return [[null, null]];
    }
  }

  function DailyPredictions (predictions, predictionIds) { //the predictions array just has times and prices... these need to be converted?
  //these will be in order of time... so just check the one before to see if it is the same day as the current one?
  //If it is the same day... then don't add it. If its a different day, then add it.
  //Should also set the time of the prediction to the 21:00 mark to align with the forward array...

    var predictionsArray = [];
    var predictionIdsArray = [];
    for(var i=0; i < predictions.length; i++ ) {
      var timeStr = predictions[i][0].utcTimeInt().utcTimeStr(); //convert the graph time into a utc date string.
      var day = timeStr.utcTime().utcTimeStr(); //convert the date string into string 'yyyy-mm-dd'
      day = day + " 16:00:00"; 
      var timeCompare = day.utcTime().utcTimeInt().graphTimeInt(); //convert the string to datestamp, then to utc int, then graphtimeint.
      
      if (predictionsArray.last() === undefined) {
        predictionsArray.push([timeCompare, predictions[i][1]]);
        predictionIdsArray.push(predictionIds[i]);
      }
      else if (predictionsArray.last()[0] !== timeCompare ) {
        predictionsArray.push([timeCompare, predictions[i][1]]);
        predictionIdsArray.push(predictionIds[i]);
      }
    }
    return [predictionsArray, predictionIdsArray];
  }

  function DailyMyPrediction (myPrediction) {
    if (myPrediction[0][0] !== null) {
      var timeStr = myPrediction[0][0].utcTimeInt().utcTimeStr();
      var day = timeStr.utcTime().utcTimeStr() +  " 16:00:00";
      var timeUpdate = day.utcTime().utcTimeInt().graphTimeInt();
      return [[timeUpdate, myPrediction[0][1]]];
    }
    else {
      return [[null, null]];
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
