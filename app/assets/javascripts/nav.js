$(document).ready(function() {

  $('#drop-nav-expand').click(function(e) {
    $('#nav-dropdown').slideToggle('fast');
    e.preventDefault();
  });

	if (matchMedia) {
		var mq = window.matchMedia("(min-width: 768px)");
		mq.addListener(WidthChange);
		WidthChange(mq);
	}

	function WidthChange(mq) {

		if (mq.matches) {
			$('.nav-dropdown').style.display="none";
		}
		else {
			// window width is less than 768px
		}
	}

});