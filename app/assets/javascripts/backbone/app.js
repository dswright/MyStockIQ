
$(function() {
  App.Models.Comment = Backbone.Model.extend();

  App.Collections.Comments = Backbone.Collection.extend({
    model: App.Models.Comment,
    url: "/comments"
  });

  App.comments = new App.Collections.Comments();
  //App.comments.render() is executed in the backbone-stocks.js file only executed on the stocks page.

  CommentView = Backbone.View.extend({
    tagName: "div",
    className: "stream",
    template: Handlebars.compile(HandlebarsTemplates['comment']()),
    // initialize: function() {
    //   _.bindAll(this, 'render'),
    //   this.model.on("change", this.render)
    // },
    render: function() {
      //console.log(this.el);
      //$(this.el).html(this.template(this.model.data))
      $(".stream").html(this.template(this.model.data));
    }
  });

  //commentView = new CommentView({model: App.Models.Comment});
});