function resizeChart() {
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockgraph-container1").css("height", height+10);
};

//Global variables 
var graph;
var chart1;
var current_range;

$(window).load(function () {
  setTimeout(function() {
    resizeChart();
    $(window).bind("orientationchange resize", resizeChart);

    seriesVar = [
      {
        name : gon.ticker_symbol
        // data : data
      }, 
      {
        name : "prediction",
        lineWidth : 0,
        marker : {
          enabled : true,
          radius : 4
        },
      },
      {
        name: "dateseries",
        lineWidth : 1
      },
      {
        name:"myprediction",
        marker : {
          enabled : true,
          radius : 4,
          color: "#DC143C"
        }
      }
    ];

    chart1 = new Highcharts.StockChart({
      chart: {
        renderTo: 'stock-div'
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
      series: seriesVar
    });


    var range_hash = {}
    var apiUrl = "/stocks/" + gon.ticker_symbol + ".json";
    chart1.showLoading('Loading data from server');
    $.getJSON(apiUrl, function (data) {

      graph = data

      chart1.series[0].setData(data["daily_prices"]);
      chart1.series[1].setData(data["predictions"]);
      chart1.series[2].setData(data["daily_forward_prices"]);
      chart1.hideLoading();

      //create the range hash...
      graph["ranges"].forEach(function(element, index, array) { 
      range_hash[element["name"]]={"x_max":element["x_range_max"], 
                                    "x_min":element["x_range_min"], 
                                    "y_max":element["y_range_max"], 
                                    "y_min":element["y_range_min"]}
                                  });

      chart1.yAxis[0].setExtremes(range_hash["1m"]["y_min"], range_hash["1m"]["y_max"]);
      chart1.xAxis[0].setExtremes(range_hash["1m"]["x_min"], range_hash["1m"]["x_max"]);

      current_range = range_hash["1m"];
    });

  
    get_ranges1 = function() {
      //for updating the graph with a new prediction, create an 
      //onclick function to refresh the predictions array on prediction click.

      //the trick is that the graph ranges has to be defined... 
      //replace these with the graph["ranges"]["3m"] variable, ect.. maybe pass that variable in through the function.
      button_type = $(this).data("button-type");
      ranges = range_hash[button_type];

      if (button_type == "1d" || button_type == "5d") {
        chart1.series[2].setData(graph["intraday_forward_prices"]);
        chart1.series[0].setData(graph["intraday_prices"]);
      }
      else {
        chart1.series[2].setData(graph["daily_forward_prices"]);
        chart1.series[0].setData(graph["daily_prices"]);
      }

      chart1.yAxis[0].setExtremes(ranges["y_min"], ranges["y_max"]);
      chart1.xAxis[0].setExtremes(ranges["x_min"], ranges["x_max"]);

      current_range = range_hash[button_type];
      
      //window.alert(range_min + range_max)
    };
  

    function predictionXMax(end_time){
      return end_time+(end_time-current_range["x_min"])*0.05;
    };
    function predictionYMax(end_price){
      return end_price+(end_price-current_range["y_min"])*0.1;
    };
    function predictionYMin(end_price){
      return end_price-(end_price-current_range["y_min"])*0.1;
    };
    
    //window.function has the affect of setting the function as a global function, and its available in the ajax function.
    window.updatePredictions = function(end_time, end_price) {
      chart1.series[3].setData([[end_time, end_price]]);

      if (end_time > current_range["x_max"]) {
        chart1.xAxis[0].setExtremes(current_range["x_min"], predictionXMax(end_time));
      }
      if (end_price > current_range["y_max"]) {
        chart1.yAxis[0].setExtremes(current_range["y_min"], predictionYMax(end_price));
      }
      if (end_price < current_range["y_min"]) {
        chart1.yAxis[0].setExtremes(current_range["y_min"], predictionYMin(end_price));
      }
    };

    window.removePrediction = function() {
      chart1.series[3].setData([null, null]);
    };

    //$("button[data-x-range-min]").click(get_ranges);
    $("button[data-button-type]").click(get_ranges1);
    //remove branding logo that says 'highcarts'
    $( "text" ).remove( ":contains('Highcharts.com')" );
  }, 0); 
});

$(document).ready(function () {
  $("#dummylink").click(window.alert1);
});
/*("#dummylink").click(function () {
  createGraph();
});*/




