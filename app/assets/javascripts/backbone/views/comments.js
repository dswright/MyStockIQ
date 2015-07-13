$(function() {

    //COMMENT VIEWS//
    App.Views.Comment = Backbone.View.extend({
        className: "comment-only-item",
        id: "stream_Comment_15",
        initialize: function () {
            this.render();
        },

        addReply: function (replyItem) {
            console.log(replyItem);
            var reply = new App.Views.Reply(replyItem);
            //var template = Handlebars.compile(HandlebarsTemplates['reply'](replyItem));
            //console.log(template());
            //$(this.el).append(template());
        },

        render: function () {
            var template = Handlebars.compile(HandlebarsTemplates['comment'](this.model.attributes));

            //in here I need to render the template for the replies..
            //it needs to set a template for each reply... or, just render a collection of replies?
            //yes, render and attach a collection of replies.
            //should be able to grab the necessary content off of the model attributes if I can work that..


            $(this.el).html(template()); //modifies the el variable.

            //this.model.attributes.replies.forEach(this.addReply, this);

            var replyList = new App.Collections.ReplyList(this.model.attributes.replies);

            var replyListView = new App.Views.ReplyList({collection: replyList, id: this.model.attributes.id}); //passes in the replies to the ReplyList view. These are set to a custom variable in the view, processed by the initialize function.

            $(this.el).append(replyListView.render().el);

            var replyForm = new App.Views.ReplyForm({collection: replyList, id: this.model.attributes.id});
            $(this.el).append(replyForm.el);

            return this;
        }
    });

    App.Views.CommentForm = Backbone.View.extend({
        tagName: "form",
        initialize: function () {
            this.render();
        },
        events: {
            "click .btn": "addComment"
        },
        addComment: function (e) {
            var input = $('.comment-form-textarea').val();
            var newComment = new App.Models.Comment({
                content: input,
                user_id: App.currentUser.id
            });
            newComment.save();
            App.commentList.add(newComment);
        },
        render: function () {
            var template = Handlebars.compile(HandlebarsTemplates['comment-form']()); //no need to pass vars to a static form.
            $(this.el).html(template);
            $(".open-prediction-form-box-tabs").after(this.el);
            return this;
        }
    });

    App.Views.CommentListView = Backbone.View.extend({
        initialize: function () {
            this.collection.on('add', this.addOne, this); //when the collection is updated, run add one.
            this.render();
        },
        addOne: function (commentItem) {
            var commentView = new App.Views.Comment({model: commentItem});
            $(".stream").prepend(commentView.render().el);
        },
        render: function () {
            console.log("LENGTH:" + this.collection.length);
            this.collection.forEach(this.addOne, this);
        }
    });
});