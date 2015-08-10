

//this is only run on the stocks page.

$(document).ready(function () {

  //executes the commentItem model. Fetches the data from /comments and renders the view for one comment.
  //comment data is stored in commentItem.attributes after the fetch.
  // App.commentItem.fetch({
  //   success: function() {
  //     App.commentView = new App.Views.Comment({model: App.commentItem});
  //   }
  // });
  //
  //


    App.currentUser = new App.Models.User(); //create the current user.
    App.currentUser.fetch({
        success: function() {
            App.commentForm = new App.Views.CommentForm({model: App.currentUser});
        }
    });

    //these are 2 variables that will be needed in the app.
    App.targetableId = gon.stock_id;
    App.targetableType = "Stock";

    App.predictionForm = new App.Views.PredictionForm();

    App.streamList = new App.Collections.StreamList({url:'/streams/'+App.targetableType+'/'+App.targetableId+'.json'});
    App.streamList.fetch({
        success: function() {
          App.streamListView = new App.Views.StreamListView({collection: App.streamList});
        }
    });
    App.replyFormView = new App.Views.ReplyForm(); //passed with no collection. Collection is passed in on load. This form is appended to the page on page load.




    //App.commentList = new App.Collections.CommentList(); //create the comment list collection.
    //
    //
    //App.commentList.fetch({ //fetch the commentList data. data gets to App.commentList.
    //    success: function() {
    //        App.commentListView = new App.Views.CommentListView({collection: App.commentList}) //render is called automatically by initialize.
    //        App.commentForm = new App.Views.CommentForm(); //render the comment form on the page.
    //    }
    //});
});

