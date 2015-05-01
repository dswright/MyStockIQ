//this could be put in the graph.js and just called later. It definitely should be put over there. Get it working first?
//the stockgraph container is not longer corrrect I dont think.
function resizeChart() {
  var height = $("#prediction-div").width()/3+30;
  $("#prediction-div").css("height", height);
  $(".stockgraph-container1").css("height", height+10);
};


//Global variables 
var predictionGraph;


$(document).ready(function () {
  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);

  seriesVar = [
    {
      name : "prices",
      dataGrouping: {
        enabled: false
      }
    },
    {
      name: "dateseries",
      lineWidth: 1,
      dataGrouping: {
        enabled: false
      }
    },
    {
      name:"myprediction",
      color: "#9E6534",
      dashStyle: 'shortdot',
      marker : {
        enabled : true,
        radius : 4,
      },
      dataGrouping: {
        enabled: false
      },
      marker : {
        enabled : true,
        radius : 5,
        symbol: "triangle"
      }
    },
    {
      name:"endprediction",
      dataGrouping: {
        enabled: false
      },
      lineWidth: 2,
      color: "#E89A58",
      marker : {
        enabled : true,
        radius : 5,
        symbol: "triangle"
      }
    }
  ];

  predictionChart = new Highcharts.StockChart({
    chart: {
      renderTo: 'prediction-div',
      panning: false, //disables time frame dragging on desktop
      pinchType: false, //disable time frame dragging on mobile.
      spacingLeft: 0,
      spacingRight: 1,
      backgroundColor:'transparent'
    },
    exporting: {
      enabled: false
    },
    tooltip: {
      crosshairs: null,
      shared: false
    },
    rangeSelector : {
      enabled: false
    },
    scrollbar: {
      enabled: false
    },
    plotOptions: {
      series: {
          turboThreshold: 0
      }
    },
    navigator: {
      enabled: false
    },
    yAxis: {
      gridLineColor: 'rgba(255, 255, 255, 0.39)',
      gridLineWidth: 0,
      lineWidth: 1,
      lineColor: 'rgba(255, 255, 255, 0.39)',
      tickColor: 'rgba(255, 255, 255, 0.39)',
      tickLength: 5,
      tickWidth: 1,
      tickPosition: "inside",
      showFirstLabel: false,
      showLastLabel: false,
      startOnTick: true,
      endOnTick: true,
      labels: {
        style: {color:"rgba(255, 255, 255, 0.39)", "font-size": "11px", "font-family":"Lato", "font-weight": "300"},
        formatter: function() {
          return "$" + this.value;
        },
        x: -10,
        y: 5
      }
    },
    xAxis: {
      minRange: 3600 * 1000,
      labels: {
        enabled: false
      },
      minorTickLength: 0,
      tickLength: 0,
      lineColor: 'rgba(255, 255, 255, 0.39)',
      lineWidth: 1,
    },
    series: seriesVar
  });


  var apiUrl = "/predictions/" + gon.prediction_id + ".json";
  $.getJSON(apiUrl, function (data) {
    
    predictionGraph = data;

    var defaults = { //defaults contains the variables that are standard to each graph.
      "data": data,
      "chart": predictionChart
    };

    graphMediator.addComponents('defaults', defaults);
    graphMediator.defaultProcessor(); //creates the daily and intradayLines components. adds the price and date lines to both of those components.

    graphMediator.createPredictionLine("daily", "prediction"); //create this predictions graph line for the stock graph only.
    graphMediator.createPredictionLine("intraday", "prediction"); //create this predictions graph line for the stock graph only.

    graphMediator.createPredictionLine("daily", "predictionend"); //create this predictions graph line for the stock graph only.
    graphMediator.createPredictionLine("intraday", "predictionend"); //create this predictions graph line for the stock graph only.

    var currentFrame = {
      timeFrame: "1Yr", 
      framesHash: graphMediator.framesHash("predictionGraph")
    };
    graphMediator.addComponents('currentFrame', currentFrame); //currentframe must be used before setRange is used.

    // sets the daily or intraday lines, depending on the timeFrame in the currentFrame.
    graphMediator.frameDependents("stockGraph");

    graphMediator.setRange();

    var buttonClick = function() {
      var buttonType = $(this).data("button-type");
      var callback = function(component) { this.timeFrame = buttonType }; //the cb is called with the .call function, so this gets reset to the component.
      graphMediator.updateComponent("currentFrame", callback);
      graphMediator.frameDependents("stockGraph");
      graphMediator.setRange(); //the current frame must be updated before set range should be used.

      //change the on-hover states based on what has been clicked.
      $(".timeframe-item-selected").switchClass("timeframe-item-selected", "timeframe-item");
      $(this).switchClass("timeframe-item", "timeframe-item-selected");
    };
    $("div[data-button-type]").click(buttonClick); //this in my object is now referring to the jquery object?

    //window.endPrediction = function(endTime, endPrice) {
    //  predictionChartFunctions.endPrediction(endTime, endPrice);
    //}

    //create prediction arrays where predictions ending that day are rounded to the end of the day to appear nicely on the 1m+ graphs.
    //graph["prediction"] = DailyPredictions(graph["my_prediction"], graph["daily_prices"].last()[0]);
    //this is not quite done yet. I need to make it work on prediction input as well.
    //that will be a bit more complex.

    //create the rangeHash to be used by the buttons.
    //note that by adding the my_prediction here, it will fall under the limited array filter.
    //the daily_predictions and daily_my_predictions are used here because the default setting is a monthly graph.
  
    //chart.yAxis[0].setExtremes(rangeHash["1m"]["yMin"], rangeHash["1m"]["yMax"]);
    //chart.xAxis[0].setExtremes(rangeHash["1m"]["xMin"], rangeHash["1m"]["xMax"]);

    //currentRange = {rangeHash:rangeHash["1m"],buttonType:"1m"};
  });
  
  //window.function has the affect of setting the function as a global function, and its available in the ajax function.
  //updatePredictions adjsuts the graph ranges to show a prediction when it is put onto the graph.

  //$("button[data-x-range-min]").click(get_ranges);
  //remove branding logo that says 'highcarts'
  $("text").remove( ":contains('Highcharts.com')" );
});





