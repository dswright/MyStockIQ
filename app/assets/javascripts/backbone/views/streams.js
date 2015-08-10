$(function() {
	App.Views.StreamListView = Backbone.View.extend({
		className: "stream",
		events: {
			"click .stream-reply-icon": "replyIconClick"
		},

		initialize: function () {
			this.collection.on('add', this.addOne, this); //when the collection is updated, run add one.
			this.render();
		},

		replyIconClick: function(event) {
			alert("blah"); //trigger the modal.. //somehow insert into that instantiation of the form, a new model...
      console.log(event);
      //var model = //get the model from the event..? yikes.
      //app.replyFormView.set('model') 
      console.log(app.replyFormView); //this view will need to be mutated somehow.

		},

		addOne: function (model) {
			//var view = new App.Views.Stream({model: model});
			if (model.attributes.type == "Comment") {
				var view = new App.Views.Comment({model: model});
				var footer = new App.Views.Footer({model: model});

				var viewEle = $(view.render().el).append(footer.render().el);
			}
			if (model.attributes.type == "Prediction") {
				var view = new App.Views.Prediction({model:model});
				var footer = new App.Views.Footer({model:model});
				var viewEle = $(view.render().el).append(footer.render().el);
			}
			this.$el.prepend(viewEle);
		},
		render: function () {
			console.log("LENGTH:" + this.collection.length);
			this.collection.forEach(this.addOne, this);
			$('.stockpage-body').append(this.$el);
		}
	});
});