
///// MODEL /////

  var CommentModel = Backbone.Model.extend({urlRoot: '/comments'});

  var commentModel = new CommentModel();

  /*commentModel.fetch({

    success: function(){
      console.log(commentModel.get('comment'));
      var commentView = new CommentView( {model: commentModel} );
       commentView.render();
    }
  });*/

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
      $('.stream').prepend(Handlebars.compile(HandlebarsTemplates['comment'](attributes)));
      //$('buttom').click(this.alertStatus).preventDefault();
    }
  });


////// Collection ///////

var CommentCollection = Backbone.Collection.extend({url: '/comments'});

var commentCollection = new CommentCollection( {model: commentModel} );



 commentCollection.fetch({

  success: function(){
    commentCollection.forEach(function(commentModel){

      var commentView = new CommentView( {model: commentModel} );
      commentView.render();
    });
  },

 })

commentCollection.on('fetch')


/////// Collection View //////

var CommentListView = Backbone.View.extend({});




