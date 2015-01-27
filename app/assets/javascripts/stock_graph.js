
//so some basic js is created here.. what can i do with it..? It's precompiled.. but I also need it to use ruby data..
//maybe make the js accept ruby params that are passed in to it?

//this gets the element by id demo and changes the text in that demo... incredible. Make sure to use the innerhtml method..
function changeText() {
  document.getElementById("demo").innerHTML = "Paragraph changed.";
};

function simpleAlert() {
  window.alert("simpleAlert")
};



function resizeChart() {
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockgraph-container1").css("height", height+10);
};

var chart1; // globally available

$(document).ready(createGraph);

function createGraph() {
  resizeChart();
  $(window).bind("orientationchange resize", resizeChart);


  seriesVar = createSeriesVar();

  chart1 = createChart1();

  get_ranges = function() {
    x_range_min = $(this).data("x-range-min");
    x_range_max = $(this).data("x-range-max");
    y_range_min = $(this).data("y-range-min");
    y_range_max = $(this).data("y-range-max");
    button_type = $(this).data("button-type");

    if (button_type == "1d" || button_type == "5d") {
      chart1.series[2].setData(gon.intraday_forward_prices);
      chart1.series[0].setData(gon.intraday_prices);
    }
    else {
      chart1.series[2].setData(gon.daily_forward_prices);
      chart1.series[0].setData(gon.daily_prices);
    }

    chart1.yAxis[0].setExtremes(y_range_min, y_range_max);
    chart1.xAxis[0].setExtremes(x_range_min, x_range_max);
    
    //window.alert(range_min + range_max)
  };

  //this works. its inside the chart variable. so dumb.
  /* $("#dummylink").click(function () {
    chart = chart1;
    chart.series[3].setData(
      [
        [1422460800000, 90]
      ]
    )
  }); */

  $("button[data-x-range-min]").click(get_ranges);
  //remove branding logo that says 'highcarts'
  $( "text" ).remove( ":contains('Highcharts.com')" );
};

/*
$document.ready( function() {
  ("#dummylink").click(function () {
    chart = chart1 // $('#stock-div').highcharts();
    chart.series[3].setData(
      [
        [1422460800000, 90]
      ]
    );
  });
});*/
/*("#dummylink").click(function () {
  createGraph();
});*/


function createSeriesVar () {
  var seriesVar = [
    {
      name : gon.ticker_symbol,
      data : gon.daily_prices
    }, 
    {
      name : "prediction",
      data : gon.predictions,
      lineWidth : 0,
      marker : {
        enabled : true,
        radius : 4
      },
    },
    {
      name: "dateseries",
      data : gon.daily_forward_prices,
      lineWidth : 1
    },
    {
      name:"myprediction",
      data: null, //[[1422460800000, 90]]
      marker : {
        enabled : true,
        radius : 4,
        color: "#DC143C"
      }
    }

  ];
  return seriesVar;
}

function createChart1 () {
  return new Highcharts.StockChart({
    chart: {
      renderTo: 'stock-div'
    },
    xAxis: {
      min: gon.graph_defaults["x_range_min"],
      max: gon.graph_defaults["x_range_max"]
          },
    yAxis: {
      min: gon.graph_defaults["y_range_min"],
      max: gon.graph_defaults["y_range_max"]
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
}






/*$(document).ready(function () {
  var width = $("#container").width();

  //resize the container height based on the width.
  var height = $("#container").width()/3+30;
  $("#container").css("height", height);
  $(".stockgraph-container1").css("height", height + 10);


  var price_array = gon.price_array;
  var ticker_symbol = gon.ticker_symbol;

  //var prediction_array = <?php echo json_encode($userpredictiongraphdata); ?>;

  //var date_array = <?php echo json_encode($datearray); ?>;

  //var min_array = <?php echo json_encode($stockattributes); ?>;

  //var tickersymbol = <?php echo json_encode($tickersymbol); ?>

  var seriesVar = [{
    name : ticker_symbol,
    data : price_array
  }];

  /*if (prediction_array != false)
  {
    prediction_array.sort();
    seriesVar.push({
    name : "Your " + tickersymbol + " prediction",
    data : prediction_array
    });
  }
  
  if (date_array[5] != null){
    var x_min = date_array[5][0];
    var x_max = date_array[5][1];
  }
  else{
    var x_min = date_array[0][0];
    var x_max = date_array[0][1];
  }

  if (min_array[5] != null){
    var y_min = min_array[5][0];
  }
  else{
    var y_min = min_array[0][0];
  }

  // Create the chart
  var chart = new Highcharts.StockChart({

    chart: {
      renderTo: 'container'
    },

    /*xAxis: {
      min: x_min,
      max: x_max
    },

    rangeSelector : {
      enabled: false
    },

    scrollbar: {
      enabled: false
    },

    /*
    yAxis: {
      min: y_min
    },

    exporting: {
      enabled: false
    },

    navigator: {
      enabled: false
    },

    series : seriesVar

  });


  $('#button0').click(function () {
    chart.yAxis[0].setExtremes(min_array[0],null);
    chart.xAxis[0].setExtremes(date_array[0][0], date_array[0][1]);
  });
  
  $('#button1').click(function() {
    chart.yAxis[0].setExtremes(min_array[1],null);
    chart.xAxis[0].setExtremes(date_array[1][0], date_array[1][1]);
  });
  
  $('#button2').click(function() {
    chart.yAxis[0].setExtremes(min_array[2],null);
    chart.xAxis[0].setExtremes(date_array[2][0], date_array[2][1]);
  });
  
  $('#button3').click(function() {
    chart.yAxis[0].setExtremes(min_array[3],null);
    chart.xAxis[0].setExtremes(date_array[3][0], date_array[3][1]);
  });

  $('#button4').click(function() {
    chart.yAxis[0].setExtremes(min_array[4],null);
    chart.xAxis[0].setExtremes(date_array[4][0], date_array[4][1]);
  });

  if (date_array[5] != null)
  {
    $('#button5').click(function() {
      chart.yAxis[0].setExtremes(min_array[5],null);
      chart.xAxis[0].setExtremes(date_array[5][0], date_array[5][1]); 
    });
  }

  //$('#button0').click(function() {
  //chart.series[0].setData(data_array0)
  //});


  // execute chart resize function to resize screen onload.
  $(window).bind("orientationchange resize", resizeChart);

  //remove branding logo that says 'highcarts'
  $( "text" ).remove( ":contains('Highcharts.com')" );

});
*/

