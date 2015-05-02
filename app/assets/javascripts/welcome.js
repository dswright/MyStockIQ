

$(document).ready(function() {

	$('.welcome-tick').change(function() {  
		$(this).parent().find(".check-div").toggleClass('check-div-on');
		$(this).parent().toggleClass('blue-blur-tile-active');
	});

	$('.welcome-tick').change(function() {

		var tickSum = $('form input[type=checkbox]:checked').size()

		if (tickSum >= 3) {
			$('.welcome-next-box').animate({'bottom': '0px'}, 300);
		}	

		else {
			$('.welcome-next-box').animate({'bottom': '-90px'}, 300);
		}

	});

});



// console.log (tickSum);