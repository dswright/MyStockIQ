function resizeChart() {
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockpage-graph").css("height", height+10);
};

//Global variables\
var stockChart;
var stockChartFunctions;
var currentRange = [];
var stockGraph;
var freezeHover = false;

$(document).ready(function () {

  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);

  seriesVar = [
    {
      name : "prices",
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
      crosshairs: null,
      shared: false,
      formatter: function() {
        if(this.series.name == 'prices') {
          if (currentRange["buttonType"] == "1D" || currentRange["buttonType"] == "5D") {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["intraday_price_ids"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/stockprices/hover_intraday/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
          else {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["daily_price_ids"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/stockprices/hover_daily/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
        }

        if(this.series.name == 'predictions') {
          if (currentRange["buttonType"] == "1D" || currentRange["buttonType"] == "5D") {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["intraday_prediction_ids"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/predictions/hover_intraday/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
          else {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["daily_prediction_ids"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/predictions/hover_daily/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
        }

        if(this.series.name == 'my_prediction') {
          if (currentRange["buttonType"] == "1D" || currentRange["buttonType"] == "5D") {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["my_prediction_id"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/predictions/hover_intraday/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
          else {
            var arrId = this.series.data.indexOf(this.point);
            var priceId = stockGraph["my_prediction_id"][arrId]; //this will always use just the 1 my_prediction_id which will always show on the graph.
            $.ajax({
              url: "/predictions/hover_daily/"+priceId, //pass the prediction id to the prediction hover partial.
              dataType: "script"
            }).done(function( script, textStatus ) {
              script //this loads in the html returned from the ajax request.
            })
          }
        }

        return false;
      }  
        /*
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

