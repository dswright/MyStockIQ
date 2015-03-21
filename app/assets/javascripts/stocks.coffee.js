function resizeChart() {
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockpage-graph").css("height", height+10);
};

//Global variables 
var stockChart;
var stockChartFunctions;
var currentRange = [];
var stockGraph;

$(document).ready(function () {

  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);

  seriesVar = [
    {
      name : gon.ticker_symbol,
      lineWidth: 1,
      dataGrouping: {
        enabled: false
      },
      line: {
        enabled:false
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
      name : "predictions",
      lineWidth : 0,
      dataGrouping: {
        enabled: false
      },
      marker : {
        enabled : true,
        radius : 4
      }
    },
    {
      name:"my_prediction",
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

  stockChart = new Highcharts.StockChart({
    chart: {
      backgroundColor:'transparent',
      renderTo: 'stock-div',
      panning: false, //disables time frame dragging on desktop
      pinchType: false, //disable time frame dragging on mobile.
      spacingLeft: 0,
      spacingRight: 1
    },
    exporting: {
      enabled: false
    },
    plotOptions: {
      spline: {
        turboThreshold: 0
      },
      series: {
        cursor: 'pointer',
        point: {
          events: {
            click: function() {
              if(this.series.name == 'my_prediction') {
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
          }
        }
      }
    },
    tooltip: {
      crosshairs: null,
      shared: false,
      enabled: false
           /*formatter: function() {
        if(this.series.name == 'my_prediction') {
          var arrId = this.series.data.indexOf(this.point);
          var predictionId = stockGraph["my_prediction_id"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.

          $.ajax({
            url: "/predictions/hover/"+predictionId, //pass the prediction id to the prediction hover partial.
            context: document.body //this tells the done function to be executed on the dom.
          }).done(function( data ) {
            $('#predictiondetailsbox').html(data).fadeIn("slow"); //this loads in the html returned from the ajax request.
          })
          var niceDate = this.x;
          niceDate = niceDate.utcTimeInt().utcTimeStr(); //.utcTime().utcTimeStr();
          return niceDate + ': $' + this.y;

        }
        else if(this.series.name == 'predictions') {
          //this.series.index is the index number of the array point.. this will give me what i need to access the predicition?
          //next create an array on the backend that can be accessed that has the corresponding prediction ids.
          //$('#predictiondetailsbox').remove();
          //get predictionid based on the datapoint index.
          var arrId = this.series.data.indexOf(this.point); //get the index point of the current array.
          var predictionId = stockGraph["active_prediction_ids"][arrId]; //use the live predictions ids array to identify the prediction id based on the array index id.

          $.ajax({
            url: "/predictions/hover/"+predictionId, //pass the prediction id to the prediction hover partial.
            context: document.body //this tells the done function to be executed on the dom.
          }).done(function( data ) {
            $('#predictiondetailsbox').html(data).fadeIn("slow"); //this loads in the html returned from the ajax request.
          })
          var niceDate = this.x;
          niceDate = niceDate.utcTimeInt().utcTimeStr();
          return niceDate + ': $' + this.y;
        }
        else {
          var niceDate = this.x;
          niceDate = niceDate.utcTimeInt().utcTimeStr();
          return '$' + this.y + ': ' + niceDate;
        }
      }*/
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
      lineColor: 'rgba(255, 255, 255, 0.39)',
      tickColor: 'rgba(255, 255, 255, 0.39)',
      tickLength: 25,
      tickWidth: 0,
      tickPosition: "inside",
      showFirstLabel: false,

      labels: {
        useHTML: true,
        style: {"padding-right":"3px","padding-left":"2px","border-bottom": "1px solid rgba(255, 255, 255, 0.39)", color:"rgba(255, 255, 255, 0.39)", "font-size": "11px", "font-family":"Lato", "font-weight": "300"},
        formatter: function() {
          return "$" + this.value;
        }
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
      stockGraph = data; //assign the data to the graph var to be used globally. Not available until after all other js is loaded initially

      stockChartFunctions = new StockGraph(stockGraph, stockChart);

      stockChartFunctions.startChart(); 
      stockChart.hideLoading();

      //$("body").on('click', 'button[data-button-type]', chartFunctions.buttonClick);
      //so this button click is being called like a closure? maybe? This thing needs to execute itself...
      $("div[data-button-type]").click(stockChartFunctions.buttonClick);

      window.inputPrediction = function(endTime, endPrice, predictionId) {
        stockChartFunctions.inputPrediction(endTime, endPrice, predictionId); //when a prediction is input, this function fires from the predicitoninput ajax call.
      }

      window.removePrediction = function() {
        stockChartFunctions.removePrediction();
      }
    }
  });

  $("text").remove( ":contains('Highcharts.com')" );


});

