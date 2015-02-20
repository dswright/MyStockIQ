function resizeChart() {
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockgraph-container1").css("height", height+10);
};

//Global variables 
var graph = {};
var chart;
var currentRange;
var rangeHash = {};

$(document).ready(function () {
  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);

  seriesVar = [
    {
      name : gon.ticker_symbol,
      dataGrouping: {
        enabled: false
      }
    },
    {
      name: "dateseries",
      lineWidth : 1,
      dataGrouping: {
        enabled: false
      }
    }, 
    {
      name : "prediction",
      lineWidth : 0,
      dataGrouping: {
        enabled: false
      },
      marker : {
        enabled : true,
        radius : 4
      },
    },
    {
      name:"myprediction",
      marker : {
        enabled : true,
        radius : 4,
        color: "#DC143C"
      },
      dataGrouping: {
        enabled: false
      }
    }
  ];

  chart = new Highcharts.StockChart({
    chart: {
      renderTo: 'stock-div'
    },
    tooltip: {
      shared: false,
      positioner: function (w,h,p) {
        return { x: p.plotX + chart.plotLeft, y: p.plotY + chart.plotTop };
      }
    },
    rangeSelector : {
      enabled: false
    },
    scrollbar: {
      enabled: false
    },
    navigator: {
      enabled: false
    },
    xAxis: {
      minRange: 3600 * 1000
    },
    series: seriesVar
  });


  var apiUrl = "/stocks/" + gon.ticker_symbol + ".json";
  chart.showLoading('Loading data from server');
  $.getJSON(apiUrl, function (data) {

    graph = data

    //create prediction arrays where predictions ending that day are rounded to the end of the day to appear nicely on the 1m+ graphs.
    graph["daily_predictions"] = DailyPredictions(graph["predictions"], graph["daily_prices"].last()[0]);
    graph["daily_my_prediction"] = DailyPredictions(graph["my_prediction"], graph["daily_prices"].last()[0]);


    var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:graph["my_prediction"]}; //set the graph limits based on predictions and my prediction
    rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d,1m,3m,6m,1yr,5yr

    if (graph["my_prediction"][0][0] === null) { //if there is no prediction set, default to the monthly settings.
      chart.series[0].setData(graph["daily_prices"]);
      chart.series[1].setData(graph["daily_forward_prices"]);
      chart.series[2].setData(graph["daily_predictions"]);
      chart.hideLoading();
      chart.yAxis[0].setExtremes(rangeHash["1m"]["yMin"], rangeHash["1m"]["yMax"]); //set the ranges to the 1m default.
      chart.xAxis[0].setExtremes(rangeHash["1m"]["xMin"], rangeHash["1m"]["xMax"]);
      currentRange = {rangeHash:rangeHash["1m"],buttonType:"1m"}; //the current range tracks the latest range button that the user has clicked.
    }
    else {
      var endTime = graph["my_prediction"][0][0];
      var bestButton = BestRange(endTime, rangeHash);
      if (bestButton === "1d" || bestButton === "5d") { //if the prediction end time is within range of the 1d or 5d buttons, set the arrays to the intraday arrays.
        chart.series[0].setData(graph["intraday_prices"]);
        chart.series[1].setData(graph["intraday_forward_prices"]);
        chart.series[2].setData(graph["predictions"]);
        chart.series[3].setData(graph["my_prediction"]);
        chart.hideLoading();
      }
      else { //otherwise set the array to the daily arrays.
        chart.series[0].setData(graph["daily_prices"]);
        chart.series[1].setData(graph["daily_forward_prices"]);
        chart.series[2].setData(graph["daily_predictions"]);
        chart.series[3].setData(graph["daily_my_prediction"]);
        chart.hideLoading();
      }

      chart.xAxis[0].setExtremes(rangeHash[bestButton]["xMin"], rangeHash[bestButton]["xMax"]); //set the extremes based on the bestButton range
      chart.yAxis[0].setExtremes(rangeHash[bestButton]["yMin"], rangeHash[bestButton]["yMax"]);
      currentRange = {rangeHash:rangeHash[bestButton], buttonType:bestButton};
    }
    

    //create the rangeHash to be used by the buttons.
    //note that by adding the my_prediction here, it will fall under the limited array filter. The my prediction and prediction filter should be differentiated.
    //the daily_predictions and daily_my_predictions are used here because the default setting is a monthly graph.
  });


  function getRanges1() {
    //the trick is that the graph ranges has to be defined... 
    //replace these with the graph["ranges"]["3m"] variable, ect.. maybe pass that variable in through the function.
    buttonType = $(this).data("button-type");
    ranges = rangeHash[buttonType];


    //originally i wanted to change the frequency with which the data arrays are reset, but it doesn't seem to matter.
    if (buttonType == "1d" || buttonType == "5d") {
      chart.series[0].setData(graph["intraday_prices"]);
      chart.series[1].setData(graph["intraday_forward_prices"]);

      //set the prediction arrays to the precise times if the graph is looking at 5d or 1d.
      chart.series[2].setData(graph["predictions"]);
      chart.series[3].setData(graph["my_prediction"]);
    }
    else { //button is not one of these, 
      chart.series[0].setData(graph["daily_prices"]);
      chart.series[1].setData(graph["daily_forward_prices"]);

      //set the prediction arrays so that today's predictions are rounded forward so that they don't appear to end before the graph does.
      chart.series[3].setData(graph["daily_my_prediction"]);
      chart.series[2].setData(graph["daily_predictions"]);
    }

    chart.yAxis[0].setExtremes(ranges["yMin"], ranges["yMax"]);
    chart.xAxis[0].setExtremes(ranges["xMin"], ranges["xMax"]);

    currentRange = {rangeHash:ranges, buttonType:buttonType};
    
  };


  function predictionYMax(endPrice){
    return endPrice+(endPrice-currentRange["rangeHash"]["yMin"])*0.1;
  };
  function predictionYMin(endPrice){
    return endPrice-(endPrice-currentRange["rangeHash"]["yMin"])*0.1;
  };

  //when a prediction is input, the graph ranges must be updated with new y max and mins so the button ranges include that
  //prediction.
  function updateRanges(endTime, endPrice){
    for (var value in rangeHash) {
      if (endPrice <= rangeHash[value]["yMin"] && endTime <= rangeHash[value]["xMax"]) {
        rangeHash[value]["yMin"] = predictionYMin(endPrice);
      }
      if (endPrice >= rangeHash[value]["yMax"] && endTime <= rangeHash[value]["xMax"]) {
        rangeHash[value]["yMax"] = predictionYMax(endPrice);
      }
    };
  };
  
  //window.function has the affect of setting the function as a global function, and its available in the ajax function.
  //updatePredictions adjsuts the graph ranges to show a prediction when it is put onto the graph.
  window.updatePredictions = function(endTime, endPrice) {
    
    graph["my_prediction"] = ([[endTime, endPrice]]);

    //reset the value of daily_my_prediction based on the new my_prediction value.
    graph["daily_my_prediction"] = DailyPredictions(graph["my_prediction"], graph["daily_prices"].last()[0]);


    ranges = rangeHash;

    var bestButton = BestRange(endTime, rangeHash);

    if (bestButton === "1d" || bestButton === "5d") { //if the prediction end time is within range of the 1d or 5d buttons, set the arrays to the intraday arrays.
      chart.series[0].setData(graph["intraday_prices"]);
      chart.series[1].setData(graph["intraday_forward_prices"]);
      chart.series[2].setData(graph["predictions"]);
      chart.series[3].setData(graph["my_prediction"]);
    }
    else { //otherwise set the array to the daily arrays.
      chart.series[0].setData(graph["daily_prices"]);
      chart.series[1].setData(graph["daily_forward_prices"]);
      chart.series[2].setData(graph["daily_predictions"]);
      chart.series[3].setData(graph["daily_my_prediction"]);
    }

    var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:graph["my_prediction"]}; //set the graph limits based on predictions and my prediction. Graph is reset based on new prediction range.
    rangeHash = new StockGraphButtons(graphSettings); //this returns all of the ranges for the butons. It is an array with keys: 1d,5d,1m,3m,6m,1yr,5yr


    chart.xAxis[0].setExtremes(rangeHash[bestButton]["xMin"], rangeHash[bestButton]["xMax"]); //set the extremes based on the bestButton range
    chart.yAxis[0].setExtremes(rangeHash[bestButton]["yMin"], rangeHash[bestButton]["yMax"]);
    currentRange = {rangeHash:rangeHash[bestButton], buttonType:bestButton};

    updateRanges(endTime, endPrice); //update ranges updates the range variables for all buttons to take into account the new prediction.

  };

  window.removePrediction = function() {
    chart.series[3].setData([[null, null]]);

    //reset the ranges on the buttons to be the original range amounts after the prediction is removed.
    var graphSettings = {intradayPrices: graph["intraday_prices"], dailyPrices:graph["daily_prices"], predictions:graph["predictions"], myPrediction:[[null,null]]};
    rangeHash = new StockGraphButtons(graphSettings); //recreate the original ranges based on the data arrays.
    
    var buttonType = currentRange["buttonType"];
    chart.yAxis[0].setExtremes(rangeHash[buttonType]["yMin"], rangeHash[buttonType]["yMax"]); //reset the ranges to the new maxes without the prediction.
    chart.xAxis[0].setExtremes(rangeHash[buttonType]["xMin"], rangeHash[buttonType]["xMax"]);

    graph["daily_my_prediction"] = [[null,null]];
    graph["my_prediction"] = [[null,null]];

    currentRange = {rangeHash:rangeHash[buttonType],buttonType:buttonType}; //reset the current range based on the new range hash.
  };

  //$("button[data-x-range-min]").click(get_ranges);
  $("button[data-button-type]").click(getRanges1);
  //remove branding logo that says 'highcarts'
  $("text").remove( ":contains('Highcharts.com')" );
});





