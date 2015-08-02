$(function() {
    App.Views.StreamListView = Backbone.View.extend({
        className: "stream",
        initialize: function () {
            this.collection.on('add', this.addOne, this); //when the collection is updated, run add one.
            this.render();
        },
        addOne: function (model) {
            //var view = new App.Views.Stream({model: model});
            if (model.attributes.type == "Comment") {
                var view = new App.Views.Comment({model: model});
                $(".stream").prepend(view.render().el);
            }
            if (model.attributes.type == "Prediction") {
                var view = new App.Views.Prediction({model:model});
                $(".stream").prepend(view.render().el);
            }
        },
        render: function () {
            console.log("LENGTH:" + this.collection.length);
            this.collection.forEach(this.addOne, this);
        }
    });
});