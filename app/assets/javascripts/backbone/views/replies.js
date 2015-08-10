$(function() {

  //REPLY VIEWS//

  App.Views.Reply = Backbone.View.extend({
    className: "stream-reply",

    initialize: function () {
      this.render();
    },
    render: function () {
      var template = Handlebars.compile(HandlebarsTemplates['stream/reply'](this.model.attributes))
      $(this.el).html(template());
      return this;
    }
  });


  App.Views.ReplySeeMore = Backbone.View.extend({
    className: "stream-reply-more",
    initialize: function() {
      this.render();
    },
    render: function() {
      var template = '<a href="" class="see-more">SEE MORE</a>';
      $(this.el).html(template);
      return this;
    }
  });

  App.Views.ReplySeeLess = Backbone.View.extend({
    className: "stream-reply-more",
    initialize: function() {
      this.render();
    },
    render: function() {
      var template = '<a href="" class="see-less">SEE LESS</a>';
      $(this.el).html(template);
      return this;
    }
  });

  App.Views.ReplyList = Backbone.View.extend({
    className: "stream-replies",
    events: {
      "click .see-more": "expand",
      "click .see-less": "collapse"
    },
    collapse: function(e){
      e.preventDefault();
      while($(this.el).children().length > 3) {
          $(this.el).children().first().remove();
      }
      var seeMore = new App.Views.ReplySeeMore();
      $(this.el).children().last().replaceWith(seeMore.render().el);
    },
    expand: function(e) {
      e.preventDefault();
      var newCollection = this.collection.slice(2,this.collection.length);

      console.log(newCollection);
      newCollection.forEach(function(replyItem) {
          var reply = new App.Views.Reply({model: replyItem});
          $(this.el).children().last().before(reply.render().el);
      }, this);

      var seeLess = new App.Views.ReplySeeLess();
      $(this.el).children().last().replaceWith(seeLess.render().el);
      //newReplies.append(seeLess.render().el);
    },
    initialize: function() {
      this.collection.on('add', this.addOne, this);
    },
    addOne: function(replyItem) {
      var reply = new App.Views.Reply({model: replyItem});
      $(this.el).append(reply.el);
    },
    render: function() {
      this.collection.first(2).forEach(this.addOne, this);
      var seeMore = new App.Views.ReplySeeMore();
      if ($(this.el).children().length >= 2) {
          $(this.el).append(seeMore.render().el);
      }
      return this;
    }
  });

  App.Views.ReplyIcon = Backbone.View.extend({
    className: "reply-icon"
  });

  //this reply form is made when the html page is first generated.
  //it accepts a stream model as a parameter of what to modify.
  //when it is first instantiated, it is not given a model.

  App.Views.ReplyForm = Backbone.View.extend({
    initialize: function() {
      this.render();
    },
    events: {
      //it needs to listen for more than the submit button within its own form..
      //it needs to listen for a click on any reply icon.
      //this is not where we add the listener.
      "submit": "addReply"
    },
    addReply: function(e) {
      var that = this;
      e.preventDefault();
      //var input = $(e.currentTarget).val();
      var input = $(e.currentTarget).find('input[type=text]').val();
      console.log(input);
      alert(input);
      //needs to add one reply, to the specific replyList that is for this comment.
      //we need to pass the collection into the reply form?
      //pass the replyList collection into thsi reply form.
      var newReply = new App.Models.Reply({ //this is interesting. Not sure if this is the est way. Seems jerryrigged.
        content: input,
        user_id: App.currentUser.id,
        repliable_type: "Comment",
        repliable_id: 10
      });
      newReply.save(null, {
        success: function(model) {
          that.collection.add(model);
        }
      });
    },
    render: function() {
      console.log("CURRENT USER:");
      console.log(App.currentUser);
      var template = Handlebars.compile(HandlebarsTemplates['stream/reply-form-modal'](App.currentUser.attributes));
      debugger;
      this.$el.html(template());
      $('body').append(this.$el);
    }
  });
});