
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
$(document).ready(function () {
  var width = $("#stock-div").width();

  //resize the container height based on the width.
  var height = $("#stock-div").width()/3+30;
  $("#stock-div").css("height", height);
  $(".stockgraph-container1").css("height", height + 10);


  var price_array = gon.price_array;
  var ticker_symbol = gon.ticker_symbol;

  var seriesVar = [{
    name : ticker_symbol,
    data : price_array
  }];

  chart1 = new Highcharts.StockChart({
    chart: {
      renderTo: 'stock-div'
    },
    xAxis: {
      min: 1406800000000,
      max: 1418342400000
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

  get_ranges = function() {
    range_min = $(this).data("x-range-min");
    range_max = $(this).data("x-range-max");
    chart1.yAxis[0].setExtremes(0,null);
    chart1.xAxis[0].setExtremes(range_min, range_max);
    //window.alert(range_min + range_max)
  };

  $("button[data-x-range-min]").click(get_ranges);
   
/*
  get_alert = function() {
    the_alert = $(this).data("the-alert")
    window.alert(the_alert)
  }

  $("button[data-the-alert]").click(get_alert)
  
  $('#button0').click(function () {
    chart1.yAxis[0].setExtremes(0,null);
    chart1.xAxis[0].setExtremes(1206800000000, 1518342400000);
  });
  */
  $(window).bind("orientationchange resize", resizeChart);

  //remove branding logo that says 'highcarts'
  $( "text" ).remove( ":contains('Highcharts.com')" );

});


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

