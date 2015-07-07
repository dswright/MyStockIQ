
$(function() {
  App.Models.Comment = Backbone.Model.extend();

  App.Collections.Comments = Backbone.Collection.extend({
    model: App.Models.Comment,
    url: "/comments"
  });

  App.comments = new App.Collections.Comments();
  //App.comments.render() is executed in the backbone-stocks.js file only executed on the stocks page.

  App.Views.Comment = Backbone.View.extend({
    el: ".stream", 
    model: App.Models.Comment,
    template: Handlebars.compile(HandlebarsTemplates['comment']()),
    // initialize: function() {
    //   _.bindAll(this, 'render'),
    //   this.model.on("change", this.render)
    // },
    render: function() {
      //console.log(this.el);
      //$(this.el).html(this.template(this.model.data))
      console.log(this.model.data);
      $(this.el).html(this.template(this.model.data));
    }
  });

  

  App.Views.Comments = Marionette.CollectionView.extend({
    el: ".stream",
    template: false,
    itemView: App.Views.Comment
    // itemViewContainer: 'tbody'
  });

  //commentView = new CommentView({model: App.Models.Comment});
});