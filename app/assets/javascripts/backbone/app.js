
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
    // initialize: function() {
    //   _.bindAll(this, 'render'),
    //   this.model.on("change", this.render)
    // },
    render: function() {
      //console.log(this.el);
      //$(this.el).html(this.template(this.model.data))
      var data = this.model.data;
      var template = Handlebars.compile(HandlebarsTemplates['comment']({content: data.content}));
      console.log(this.model.data);
      $(this.el).html(template());
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