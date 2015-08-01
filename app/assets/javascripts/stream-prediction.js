$(document).ready( function() {

	$(".stream-reply-more > .see-more").on( "click", function(event) {
		event.preventDefault();

		$(this).closest('.stream-replies').find('#stream-reply-hide').toggle();
		$(this).text(function(i, v) {
          return v === 'SEE MORE' ? 'SEE LESS' : 'SEE MORE';
      	})
	});

});
