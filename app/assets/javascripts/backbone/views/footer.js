
$(function() {
  App.Views.Footer = Backbone.View.extend({
    className: "stream-footer",
    initialize: function () {
      this.render();
    },
    render: function () {
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