function resizeChart() {
  var height = $("#stock-div").width()/2.25+30;
  $("#stock-div").css("height", height);
  $(".stockpage-graph").css("height", height+10);
};

//Global variables. Move these inside the doc ready after debugging is complete.
var stockGraph;

$(document).ready(function () {

  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);

  /* This function should work for setting each data point back 5 hours, but it doesnt. Getting rid of it for now, as the graph times are not critical.
  Highcharts.setOptions({
    global: {
       getTimezoneOffset: function (timestamp) {
         console.log("here?");
         moment.tz.add('America/New_York|EST EDT|50 40|0101|1Lz50 1zb0 Op0');
         var zone = 'America/New_York';
         var timezoneOffset = -moment.tz(timestamp, zone).utcOffset();
         alert("TZ HERE"+timezoneOffset);
         return timezoneOffset;
       }
    }
  });
*/

  seriesVar = [
    {
      name : "prices",
      lineWidth: 2,
      dataGrouping: {
        enabled: false
      }
    },
    {
      name: "dateseries",
      lineWidth : 0,
      dataGrouping: {
        enabled: false
      }
    },
    {
      name : "predictions",
      lineWidth : 0,
      color: "#90ED7D",
      dataGrouping: {
        enabled: false
      },
      marker : {
        enabled : true,
        radius : 5,
      }
    },
    {
      name:"my_prediction",
      color: "#f7a35c",      
      marker : {
        enabled : true,
        radius : 5,
      },
      dataGrouping: {
        enabled: false
      }
    }
  ];

  stockChart = new Highcharts.StockChart({
    chart: {
      backgroundColor:'transparent',
      renderTo: 'stock-div',
      panning: false, //disables time frame dragging on desktop
      pinchType: false, //disable time frame dragging on mobile.
      spacingLeft: 50,
      spacingRight: 1,
      plotBorderWidth: 1,
      plotBorderColor: 'rgba(255, 255, 255, 0.1)'
    },
    exporting: {
      enabled: false
    },
    plotOptions: {
      series: {
        turboThreshold: 0,
        cursor: 'pointer',
        marker: {
          states: {
            hover: { //select state doesnt work here.
              radius: 4, //radius of the on-hover ball
              lineWidth: 2, //width of the line around the ball
              lineColor: "#FFF"
            }
          }
        },
        states: { //no select state for the series.
          hover: {
            lineWidthPlus: 0,
            halo: {
              size: 0 //gets rid of the halo effect.
            }
          }
        },
        /*point: {
          events: {
            select: function() {
              //if (freezeHover == false) {
                this.series.update({
                  color: "#FFF"
                });
              //}
              //else {
              //  freezeHover = false;
              //}

              /*if(this.series.name == 'my_prediction') {
                var arrId = this.series.data[0].index;
                var predictionId = stockGraph["my_prediction_id"][arrId];
                location.href = '/predictions/'+predictionId;  
              }
              if(this.series.name == 'predictions') {
                var arrId = this.series.data[0].index;
                var predictionId = stockGraph["prediction_ids"][arrId];
                location.href = '/predictions/'+predictionId;  
              
            }
          }
        }*/
      }
    },
    tooltip: {
      enabled: false,
      crosshairs: null,
      shared: false
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
    yAxis: {
      gridLineColor: 'rgba(255, 255, 255, 0.39)',
      gridLineWidth: 0,
      lineWidth: 1,
      lineColor: 'rgba(255, 255, 255, 0.1)',
      tickColor: 'rgba(255, 255, 255, 0.2)',
      tickLength: 0,
      tickWidth: 1,
      tickPosition: "outside",
      showFirstLabel: false,
      showLastLabel: false,
      startOnTick: true,
      endOnTick: true,
      labels: {
        style: {color:"#FFFFFF", "font-size": "11px", "font-family":"Lato", "font-weight": "300"},
        formatter: function() {
          return "$" + this.value;
        },
        align:'left',
        x: -38,
        y: 4
      },
      opposite:false
    },
    xAxis: {
      minRange: 3600 * 1000,
      minorTickLength: 0,
      tickLength: 0,
      lineColor: 'rgba(255, 255, 255, 0.1)',
      lineWidth: 1,
      labels: {
        style: {color:"#FFFFFF", "font-size": "11px", "font-family":"Lato", "font-weight": "300"}
      }
    },

    series: seriesVar
  });

  var apiUrl = "/stockprices/" + gon.ticker_symbol + ".json";
  var getRanges1;
  
  $.ajax({
    type: 'GET',
    url: apiUrl,
    async: true,
    cache: true,
    crossDomain: false,
    contentType: "application/json; charset=utf-8",
    dataType: 'json',
    success: function (data, status) {
      stockGraph = data; //assign the data to the graph var to be used globally. Delete this once debugging is done.

      var defaults = { //defaults contains the variables that are standard to each graph.
        "data": data,
        "chart": stockChart
      };

      var newGraph = new BuildStockGraph(defaults);

      newGraph.launch();

      $("div[data-button-type]").click(newGraph.buttonClick);

      window.inputPrediction = function(endTime, endPrice, predictionId, marker) {
        console.log("inside the inputPrediction");
        newGraph.inputPrediction(endTime, endPrice, predictionId, marker); //when a prediction is input, this function fires from the predicitoninput ajax call.
      }

      window.removePrediction = function() {
        newGraph.removePrediction();
      }
    }
  });

  $("text").remove( ":contains('Highcharts.com')" );
});