
$(function() {

  App.Models.User = Backbone.Model.extend({urlRoot: '/users'});

  App.currentUser = new App.Models.User({id: 1});

  App.Models.Comment = Backbone.Model.extend({urlRoot:'/comment'}); //took out the url root. No longer fetching the single comment model from the api.

  App.Views.Comment = Backbone.View.extend({
    initialize: function() {
      this.render();
    },
    render: function() {
      var template = Handlebars.compile(HandlebarsTemplates['comment'](this.model.attributes));
      $(this.el).html(template()); //modifies the el variable.
      return this;
    }
  });

  App.Views.CommentForm = Backbone.View.extend({
    tagName: "form",
    initialize: function() {
      this.render();
    },
    events: {
      "click .btn": "addComment"
    },
    alertStatus: function(e) {
      var input = $('.comment-form-textarea').val();
      alert(input);
    },
    addComment: function(e) {
      var input = $('.comment-form-textarea').val();
      App.newComment = new App.Models.Comment({
        content: input,
        user_id: App.currentUser.id
      });
      App.newComment.save();
      console.log(App.newComment);
      App.commentList.add(App.newComment);
    },
    render: function() {
      var template = Handlebars.compile(HandlebarsTemplates['comment-form']()); //no need to pass vars to a static form.
      $(this.el).html(template);
      $(".open-prediction-form-box-tabs").after(this.el);
      return this;
    }
  });

  App.Collections.CommentList = Backbone.Collection.extend({
    url: "/comments"
  })

  App.commentList = new App.Collections.CommentList();

  App.Views.CommentListView = Backbone.View.extend({
    initialize: function() {
      this.collection.on('add', this.addOne, this); //when the collection is updated, run add one.
      this.render();
    },
    addOne: function(commentItem) {
      var commentView = new App.Views.Comment({model:commentItem});
      $(".stream").prepend(commentView.render().el);
    },
    render: function() {
      this.collection.forEach(this.addOne, this);
    }
  });

});