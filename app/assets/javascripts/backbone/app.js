
$(function() {
  App.Models.Album = Backbone.Model.extend()

  App.album = new App.Models.Album({ title: 'Bitches Brew'});
  // child {cid: "c2", attributes: Object, _changing: false, _previousAttributes: Object, changed: Object…}
  App.album.get('title');
  // “Bitches Brew”
  App.album.set({ title: 'Sketches of Spain' });
  // child {cid: "c2", attributes: Object, _changing: false, _previousAttributes: Object, changed: Object…}
  App.album.get('title');
  // ”Sketches of Spain”


  App.Collections.Albums = Backbone.Collection.extend({
    model: App.Models.Album,
    url: "/comments"
  });

  function loadComment() {
    $.get('template.mst', function(template) {
      var rendered = Mustache.render(template, {name:"Luke"});
      $('#target').html(rendered);
    });
  }

  App.albums = new App.Collections.Albums();
  App.albums.fetch({
    success: function() {
      var view = App.albums.first().get('comments')[0];
      var output = Mustache.render("{{content}} spends {{created_at}}", view);
      $.get('template.mst', function(template) {
        var rendered = Mustache.render(template, view);
        $('#stream').html(rendered);
      });

      console.log(output);
    }
  });
 

});