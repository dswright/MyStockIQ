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

    var newGraph = new BuildPredictionGraph(defaults);
    newGraph.launch();
    $("div[data-button-type]").click(newGraph.buttonClick);

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

  });
  
  //window.function has the affect of setting the function as a global function, and its available in the ajax function.
  //updatePredictions adjsuts the graph ranges to show a prediction when it is put onto the graph.

  //$("button[data-x-range-min]").click(get_ranges);
  //remove branding logo that says 'highcarts'
  $("text").remove( ":contains('Highcharts.com')" );
});





