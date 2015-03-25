


// For "Select Profile Image" hides defalt chose file 
// button and applies styled one

$(document).on('change', '.btn-file :file', function() {
    var input = $(this),
        numFiles = input.get(0).files ? input.get(0).files.length : 1,
        label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
    input.trigger('fileselect', [numFiles, label]);
});

$(document).ready( function() {
    $('.btn-file :file').on('fileselect', function(event, numFiles, label) {
      console.log(numFiles);
      console.log(label);
      $('#signup-label').html(label);
    });
});