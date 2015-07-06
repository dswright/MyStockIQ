App.Collections.Albums = Backbone.Collection.extend
  model: App.Models.Album
  url: "/users/2/albums"

Comment = Backbone.Model.extend({urlRoot: '/comments'});

var comment = new Comment({id: 1});

comment.fetch();


var CommentView = Backbone.View.extend({
	template: _.template('<p><%= content %></p>'),
	tagName: 'a',
	className: 'comment',
	id: 'comment_id',
	render: function(){
		var attributes = this.model.toJSON();
		this.$el.html(attributes);
	}

});

var commentView = new CommentView({ model: comment , el: $("#comment_view") });
commentView.render();
console.log(commentView.el);
