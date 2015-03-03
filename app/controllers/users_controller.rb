class UsersController < ApplicationController
  
  #this method automatically loads the index view newuser/new.html.erb. 
  #And all variables with @ are available in the view.
  #the Newuser.new creates a new user from the model.
  
  def show
    return if user_logged_in? #redirects the user to the login page if they are not logged in.
        
    #Logged in user
    @current_user = current_user

    #Target user
    @user = User.find_by(username: params[:username])

    #All active predictions by target user
    @predictions = Prediction.where(active: 1, user_id: @user.id)

    #All streams about target user
    streams = Stream.where(target_type: @user.class.name, target_id: @user.id)

    #Run every new stream through the streammaker recursively..
    @stream_hash_array = Stream.stream_maker(streams, 0)

    #Determines relationship between current user and target user
    @target = @user

    @comment_header = "Comment on #{params[:username]}"
    @comment_stream_inputs = "User:#{@user.id}"

    @comment_landing_page = "users:#{@user.username}"
    @stream_comment_landing_page = "users:#{@user.username}"
    

    #creates empty comment object to plug into the form.
    #right now the comment takes: id, content, ticker_symbol, stream_id, created_at, updated_at. Stream id should be implicit..
    @comment = Comment.new 
    @like = Like.new

    #@comment = current_user.comments.build  #this assumes an association between comments and current user. Which does not exist.
  end

  def new
  	@user = User.new
  	#why create a new empty user here? To be passed into the user creation form for setting the params.
  end

  def create
    #this uses the result from the user_params function to create a new user.
  	@user = User.new(user_params)
    #this saves the new user to the database.
  	if @user.save 
      log_in @user
      flash[:success] = "Welcome to the Stock Hero"

      #redirect to user profile page
  		redirect_to "/users/#{@user.username}"

  	else
      flash.now[:danger] = 'Invalid Form'
  		render 'sessions/new'
  	end
	end

  private

	  def user_params
	  	#This returns a version of the params hash with only the permitted attributes.
	  	#So :user get's returned, but wittled down to just these 4 attributes.
	  	#params[:user] is what returns the values from the form in hash.
	  	#One way of creating a new user from the params hash would be @user = User.new(params[:user])
	  	#instead we use this very fancy line below that also permits only specific form fields.
	  	#user is the object created by passing the @user variable into the Ruby form.
	    params.require(:user).permit(:username, :email, :password,
	                                 :password_confirmation)
	  end


end
