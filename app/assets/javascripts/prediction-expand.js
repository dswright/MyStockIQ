
$(document).ready(function() {


// prediction item expand

  $('.expand').click(function(e) {

    // figure out if we're open or closed
    $el = $(this).parent().children('.toggle');

    // if closed
    if($el.is(':visible')) {
      $el.slideToggle(function(){
       	e.preventDefault();
      });
       
    } else {
      $el.slideToggle(function(){
      e.preventDefault(); 
      });
    }

  });



// prediction item first comment expand


  $('.comment-expand').click(function(e) {

  	e.preventDefault();
    // figure out if we're open or closed
    $el = $(this).parent().parent().parent().children('.prediction-comments').children('.comment-toggle');   //().children('.prediction-comments').children('.comment-toggle');
    console.log($el);
    // if closed
    if($el.is(':visible')) {
      $el.slideToggle(function(){
       	e.preventDefault();
      });
       
    } else {
      $el.slideToggle(function(){
      e.preventDefault(); 
      });
    }

  });



// prediction item first nested comment expand


  $('.nested-comment-1').click(function(e) {

  	e.preventDefault();
    // figure out if we're open or closed
    $el = $(this).parent().parent().parent().children('.nested-toggle-1');

    // if closed
    if($el.is(':visible')) {
      $el.slideToggle(function(){
       	e.preventDefault();
      });
       
    } else {
      $el.slideToggle(function(){
      e.preventDefault(); 
      });
    }

  });





});
