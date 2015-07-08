

//this is only run on the stocks page.

$(document).ready(function () {

  //executes the commentItem model. Fetches the data from /comments and renders the view for one comment.
  //comment data is stored in commentItem.attributes after the fetch.
  // App.commentItem.fetch({
  //   success: function() {
  //     App.commentView = new App.Views.Comment({model: App.commentItem});
  //   }
  // });

  App.commentList.fetch({
    success: function() {
      App.commentListView = new App.Views.CommentListView({collection: App.commentList}) //render is called automatically by initialize.
      App.commentForm = new App.Views.CommentForm();
    }
  });



});