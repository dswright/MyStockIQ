
$(function() {
  App.Models.Comment = Backbone.Model.extend({urlRoot: '/comments'}); //

  App.commentItem = new App.Models.Comment({id:30});

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
      "click .btn": "alertStatus"
    },
    alertStatus: function(e) {
      var input = $('.comment-form-textarea').val();
      alert(input);
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
      $(this.el).append(commentView.render().el); //its getting the el of Comment after render has run.
    },
    render: function() {
      this.collection.forEach(this.addOne, this);
      $(".stream").html(this.el);
    }
  });

});