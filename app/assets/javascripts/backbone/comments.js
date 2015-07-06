App.Collections.Albums = Backbone.Collection.extend
  model: App.Models.Album
  url: "/users/2/albums"