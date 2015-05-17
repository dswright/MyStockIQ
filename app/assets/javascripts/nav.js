
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


/* Toggles mobile search field */

$(document).ready(function() {

  $('#drop-search-expand').click(function(e) {
    $('#search-dropdown').slideToggle('fast');
    e.preventDefault();
    $('#mobile-dropdown').focus();
  });

});


// Desktop search

  $(function() {
    $("#dropdown").autocomplete({
      delay: 500,
      minLength:1,
      source: function(request, response) {
        $.getJSON("/stocks/"+request.term+".json",
        function(data) {
          var array = data.stock_data.map(function(m) {
            return {
              label: m[0],
              stock_name: m[1],
              url: "/stocks/" + m[0] + "/"
            }
          });
          response(array);
        });
      },
      focus: function(event, ui) {
        // prevent autocomplete from updating the textbox
        event.preventDefault();
      },
      select: function(event, ui) {
        // prevent autocomplete from updating the textbox
        event.preventDefault();
        // navigate to the selected item's url
        window.open(ui.item.url);
      }
    })

    .autocomplete("instance")._renderItem = function( ul, item ) {
        return $( "<li>" ).append( "<a>" + "$" + item.label + " (" + item.stock_name + ")" + "</a>" ).appendTo( ul );
    };


	if (mq.matches == true) {
      $(".ui-autocomplete").insertAfter($('#autocomplete'));
    }


  });


// Mobile search

  $(function() {
    $("#mobile-dropdown").autocomplete({
      delay: 500,
      minLength:1,
      source: function(request, response) {
        $.getJSON("/stocks/"+request.term+".json",
        function(data) {
          var array = data.stock_data.map(function(m) {
            return {
              label: m[0],
              stock_name: m[1],
              url: "/stocks/" + m[0] + "/"
            }
          });
          response(array);
        });
      },
      focus: function(event, ui) {
        // prevent autocomplete from updating the textbox
        event.preventDefault();
      },
      select: function(event, ui) {
        // prevent autocomplete from updating the textbox
        event.preventDefault();
        // navigate to the selected item's url
        window.open(ui.item.url);
      }
    })

    .autocomplete("instance")._renderItem = function( ul, item ) {
        return $( "<li>" ).append( "<a>" + "$" + item.label + " (" + item.stock_name + ")" + "</a>" ).appendTo( ul );
    };

	if (mq.matches == false) {
    	$(".ui-autocomplete").insertAfter($('#mobile-autocomplete'));
	}
  });



$(function() {
  $('.nav-item-div a[href^="/' + location.pathname.split("/")[1] + '"]').addClass('nav-active');
});


