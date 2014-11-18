class UsersController < ApplicationController
  
  #this method automatically loads the index view newuser/new.html.erb. 
  #And all variables with @ are available in the view.
  #the Newuser.new creates a new user from the model.
  
  def show
    @current_user = current_user
    @allusers = User.all

    @user = User.find_by(username: params[:username])

    #all user posts are assigned to @posts, with the posts split by page to prevent displaying too many posts.
    @posts = @user.streams
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
      log_in(@user)
      flash[:success] = "Welcome to the Stock Hero"
      #redirect to the newusers_path => defined in the routes file. 
  		redirect_to login_path
  	else
  		render template: 'sessions/new'
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
