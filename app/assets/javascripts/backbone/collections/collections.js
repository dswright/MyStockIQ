
$(function() {

    App.Collections.CommentList = Backbone.Collection.extend({
        url: "/comments"
    });

    App.Collections.ReplyList = Backbone.Collection.extend();
});


