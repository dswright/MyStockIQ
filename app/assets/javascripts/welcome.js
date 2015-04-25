

$(document).ready(function() {

	$('.welcome-tick').change(function() {  
		$(this).parent().find(".check-div").toggleClass('check-div-on');
	});

	$('.welcome-tick').change(function() {

		var tickSum = $('form input[type=checkbox]:checked').size()
		console.log (tickSum);

		if (tickSum >= 3) {
			$('.welcome-next-box').show(500);
		}	

		else {
			$('.welcome-next-box').hide(500);
		}

	});

});






  //     if($('.foot').hasClass('slide-up')) {
  //       $('.foot').addClass('slide-down', 1000, 'easeOutBounce');
  //       $('.foot').removeClass('slide-up'); 
  //     } else {
  //       $('.foot').removeClass('slide-down');
  //       $('.foot').addClass('slide-up', 1000, 'easeOutBounce'); 
  //     }
  // });




		// if ();

		// window.alert("sometext");


	// console.log ($(this));

	// object that stores count, used
	// used: array of IDs of welcome tick ID
	// function - if this.id in used, count -1 and destroy ID in used
	// function - if this.id not in used, count +1 and create ID in used
	// function - if count >= 3 load div