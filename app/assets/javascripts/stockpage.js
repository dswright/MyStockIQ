


$(document).ready(function() {


  $(':checkbox').change(function() {

  	if(this.checked) {
    	$('.stockpage-sidebar-prediction-form').slideToggle('fast');
    }
  });

});


