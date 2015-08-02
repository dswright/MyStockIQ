
$(function() {

    App.Collections.CommentList = Backbone.Collection.extend({
        url: "/comments"
    });

    App.Collections.ReplyList = Backbone.Collection.extend();

    App.Collections.StreamList = Backbone.Collection.extend({
        initialize: function(options) {
            this.url = options.url;
        }
    });
});


