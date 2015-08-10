
$(function() {
  App.Views.Footer = Backbone.View.extend({
    className: "stream-footer",
    initialize: function () {
      this.render();
    },
    render: function () {
      //there won't really be a footer html template. All we need is the streamfooter div.
      
      //pass the footer an instance of the reply icon that has already been created..

      // var replyIconView = new App.View.ReplyIcon({model: this.model}); //reply icon has the model that we are in.. what does it need? 
      // this.$el.append((replyIconView.render().el)); //apply the replyIconView.

      var template = Handlebars.compile(HandlebarsTemplates['stream/footer'](this.model.attributes))
      $(this.el).html(template());
      return this;
    }

  });
});

$(function() {
  App.Views.ReplyIcon = Backbone.View.extend({
    className: "stream-footer",
    initialize: function () {
      this.render();
    },
    render: function () {
      var template = Handlebars.compile(HandlebarsTemplates['stream/reply'](this.model.attributes))
      $(this.el).html(template());
      return this;
    }

  });
});