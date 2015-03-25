


// For "Select Profile Image" hides defalt chose file 
// button and applies styled one

$(document).ready(function() {

	$(document).on('change', '.btn-file :file', function() {
	    var input = $(this);
	    input.trigger('fileselect');
	});

    $('.btn-file :file').on('fileselect') {
        $('input').html(contentString);
    });

});
