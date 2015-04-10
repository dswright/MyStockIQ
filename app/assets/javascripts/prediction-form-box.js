$(document).ready( function() {

/////////////////// PREDICTION FORM BOX ///////////////


// PREDICTION FORM TABBER //

  $(function() {
    $( "#tabs" ).tabs();

      $('#prediction-tab').click(function() {
	    $('#price').focus();
	  });

	  $('#comment-only-tab').click(function() {
	    $('#comment-only').focus();
	  });

  });

  $( ".selector" ).tabs({
    active: 1

  });



// PREDICTION FORM CHARACTER COUNTER //

  function countChar(val) {
    var len = val.value.length;
    if (len >= 140) {
      val.value = val.value.substring(0, 140);
    } else {
      $('#charNum').text(140 - len);
    }
  };


// COMMENT ONLY FORM CHARACTER COUNTER //

  function countCommentChar(val) {
    var len = val.value.length;
    if (len >= 140) {
      val.value = val.value.substring(0, 140);
    } else {
      $('#commentCharNum').text(140 - len);
    }
  };



  /////////////// OPEN PREDICTION FORM BOX ///////////////


// PREDICTION FORM TABBER //

  $(function() {
    $( "#open-tabs" ).tabs();

	  $('#open-prediction-close-tab').click(function() {
	    $('#close-comment').focus();
	  });

	  $('#open-prediction-comment-tab').click(function() {
	    $('#open-comment').focus();
	  });

  });

  $( ".selector" ).tabs({
    active: 1
  });

  $('#open-prediction-close-tab').click(function() {
    $('#close-comment').focus();
  });



// PREDICTION FORM CHARACTER COUNTER //

  function openCountChar(val) {
    var len = val.value.length;
    if (len >= 140) {
      val.value = val.value.substring(0, 140);
    } else {
      $('#openCharNum').text(140 - len);
    }
  };


// COMMENT ONLY FORM CHARACTER COUNTER //

  function openCountCommentChar(val) {
    var len = val.value.length;
    if (len >= 140) {
      val.value = val.value.substring(0, 140);
    } else {
      $('#openCommentCharNum').text(140 - len);
    }
  };




});


