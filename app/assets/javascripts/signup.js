


// For "Select Profile Image" hides defalt chose file 
// button and applies styled one

$(document).ready(function() {

	$(document).on('change', '.btn-file :file', function() {
	    var input = $(this);
	    label = input.val().replace(/\\/g, '/').replace();
	    input.trigger('fileselect', [0, label]);
	});
});


$(document).ready( function() {
	$('.btn-file :file').on('fileselect', function(event, numFiles, label) {
    	console.log(numFiles);
    	console.log(label);
    $('#signup-label').html(label);
});