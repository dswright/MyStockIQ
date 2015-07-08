
/*
//this is only run on the stocks page.

$(document).ready(function () {

  //executes the App.comments model. Fetches the data from /comments and renders the view for one comment.
  App.comments.fetch(
    {
      success: function() {
        App.comments.data = App.comments.first().get('comments')[0];
        commentView = new CommentView({ model: commentsModel });
        commentView.render();
      }
    }
  );
});
*/