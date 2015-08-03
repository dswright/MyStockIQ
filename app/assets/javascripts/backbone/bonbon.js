/*
///// MODEL /////

  var CommentModel = Backbone.Model.extend({urlRoot: '/comments'});

  var commentModel = new CommentModel();

  commentModel.fetch({

    success: function(){
      console.log(commentModel.get('comment'));
      var commentView = new CommentView( {model: commentModel} );
       commentView.render();
    }
  });

////// View /////////

  var CommentView = Backbone.View.extend({
    tagName: "div",
    className: "stream",
    //template: _.template('<button><%= comment.content %></button>'),
    
    events: {
              "click button": "alertStatus"
    },

    alertStatus: function(e){
      alert('Hey you clicked the content');
    },
    render: function() {
      //$(this.el).html(this.template(this.model.data))
      var attributes = this.model.attributes;
      //var html = '<div>' + this.model.get('comment').content + '</div>';
      $('.stream').prepend(Handlebars.compile(HandlebarsTemplates['example'](attributes)));
      //$('buttom').click(this.alertStatus).preventDefault();
    }
  });

  var StreamView = Backbone.View.extend({
    tagName: "div",
    className: "stream",
    //template: _.template('<button><%= comment.content %></button>'),
    
    events: {
              "click button": "alertStatus"
    },

    alertStatus: function(e){
      alert('Hey you clicked the content');
    },
    render: function() {
      //$(this.el).html(this.template(this.model.data))
      var attributes = this.model.attributes;
      //var html = '<div>' + this.model.get('comment').content + '</div>';
      $('.stream').prepend(Handlebars.compile(HandlebarsTemplates['comment'](attributes)));
      //$('buttom').click(this.alertStatus).preventDefault();
    }
  });

////// Collection ///////

var CommentCollection = Backbone.Collection.extend({url: '/comments'});
var commentCollection = new CommentCollection( {model: commentModel} );

commentCollection.fetch({

  success: function(){
      var commentListView = new CommentListView( {collection: commentCollection} );
      commentListView.render();
  },

 });


 var StreamCollection = Backbone.Collection.extend({url: '/streams.json'});
 var streamCollection = new StreamCollection();

streamCollection.fetch({

  success: function(){
    var streamsView = new StreamsView( {collection: streamCollection} );
    streamsView.render();
  }
});

//commentCollection.on('fetch')


/////// Collection View //////

var CommentListView = Backbone.View.extend({
  initialize: function(){
    this.collection.on('add', this.addOne, this);
    this.collection.on('reset', this.addAll, this);
  },

  render: function(){
    this.addAll();
  },

  addOne: function(commentModel){
    var commentView = new CommentView({model: commentModel});
    commentView.render();
  },

  addAll: function(){
    this.collection.forEach(this.addOne, this);
  }

});

var StreamsView = Backbone.View.extend({
  initialize: function(){
    this.collection.on('add', this.addOne, this);
    this.collection.on('reset', this.addAll, this);
  },

  render: function(){
    this.addAll();
  },

  addOne: function(streamModel){
    var streamView = new StreamView({model: streamModel});
    streamView.render();
  },

  addAll: function(){
    this.collection.forEach(this.addOne, this);
  }

})



*/