$(function() {

    //REPLY VIEWS//

    App.Views.Reply = Backbone.View.extend({
        className: "stream-item-comments",
        id: "new-reply-container",

        initialize: function () {
            this.render();
        },
        render: function () {
            console.log("ATTRS:");
            console.log(this.model.attributes);
            var template = Handlebars.compile(HandlebarsTemplates['reply'](this.model.attributes))
            $(this.el).html(template());
            return this;
        }
    });


    App.Views.ReplyTotal = Backbone.View.extend({
        className: "stream-comment-header",
        initialize: function() {
            this.render();
        },
        render: function() {
            var template = "<p>Replies</p>";
            $(this.el).html(template);
            return this;
        }
    });

    App.Views.ReplyList = Backbone.View.extend({
        className: "stream-item-comments",
        initialize: function() {
            this.collection.on('add', this.addOne, this);
        },
        addOne: function(replyItem) {
            var reply = new App.Views.Reply({model: replyItem});
            $(this.el).prepend(reply.el);
        },
        render: function() {
            var replyTotal = new App.Views.ReplyTotal();
            $(this.el).prepend(replyTotal);

            this.collection.forEach(this.addOne, this);
            return this;
        }
    });

    App.Views.ReplyForm = Backbone.View.extend({
        tagName: "form",
        className: "new_reply",
        initialize: function() {
            this.render();
        },
        events: {
            "submit": "addReply"
        },
        addReply: function(e) {
            e.preventDefault();
            //var input = $(e.currentTarget).val();
            var input = $(e.currentTarget).find('input[type=text]').val();
            console.log(input);
            alert(input);
            //needs to add one reply, to the specific replyList that is for this comment.
            //we need to pass the collection into the reply form?
            //pass the replyList collection into thsi reply form.
            var newReply = new App.Models.Reply({
                content: input,
                user_id: App.currentUser.id,
                repliable_type: "Comment",
                repliable_id: this.id
            });
            newReply.save();
            this.collection.add(newReply);
        },
        render: function() {
            console.log("CURRENT USER:");
            console.log(App.currentUser);
            var template = Handlebars.compile(HandlebarsTemplates['reply-form'](App.currentUser.attributes));
            $(this.el).html(template());
            return this;
        }

    });
});