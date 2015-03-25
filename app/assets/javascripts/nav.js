
/* Toggles mobile nav div */

$(document).ready(function() {

  $('#drop-nav-expand').click(function(e) {
    $('#nav-dropdown').slideToggle('fast');
    e.preventDefault();
  });

});


/* Hides mobile nav menu on viewport wider than 768px */

if (matchMedia) {
	var mq = window.matchMedia("(min-width: 768px)");
	mq.addListener(WidthChange);
	WidthChange(mq);
}

// media query change
function WidthChange(mq) {

	if (mq.matches) {
		$('#nav-dropdown').hide();
	}
	else {
		// window width is less than 500px
	}

}

