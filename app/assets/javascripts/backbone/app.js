

  var CommentModel = Backbone.Model.extend({urlRoot: '/comments'});

  var commentModel = new CommentModel();
  commentModel.fetch({
    success: function(){
      console.log(commentModel.get('comment'));
      var commentView = new CommentView({model: commentModel});
      commentView.render();
    }
  });
/*
  App.Collections.Comments = Backbone.Collection.extend({
    model: App.Models.Comment,
    url: '/comments'
  });

  App.comments = new App.Collections.Comments(); */

  //App.comments.render() is executed in the backbone-stocks.js file only executed on the stocks page.

  var CommentView = Backbone.View.extend({
    tagName: "div",
    className: "stream",
    //template: Handlebars.compile("<div><p>{{content}}</p></div>"),

    render: function() {
      //$(this.el).html(this.template(this.model.data))
      //var attributes = this.model.toJSON();
      //console.log(attributes);
      var html = '<div>' + this.model.get('comment').content + '</div>';
      console.log(html);
      $(this.el).html(html);
    }
  });


