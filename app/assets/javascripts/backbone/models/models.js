
$(function() {
    App.Models.User = Backbone.Model.extend({urlRoot: '/user'}); //use this to fetch the current user.
    App.Models.Comment = Backbone.Model.extend({urlRoot:'/comment'}); //took out the url root. No longer fetching the single comment model from the api.
    App.Models.Reply = Backbone.Model.extend({urlRoot:'/reply'}); //use this to post new replies to the server. Individual replies are not fetched.
});