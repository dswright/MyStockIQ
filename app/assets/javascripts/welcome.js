

$(document).ready(function() {


	$('#welcome-tick').change(function() {  
		
		$(this).parent().find(".check-div-off").toggleClass('check-div-on');

	});


});



// 		$(this).children(":first").toggle();


// $(this).find(".check-class-off").