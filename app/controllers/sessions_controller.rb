class SessionsController < ApplicationController
  def new
  end

   def create

    #if the email field contains an '@' symbol its a an email address, otherwise it's a username.
    if params[:session][:email].downcase.include? "@"
      #use find_by fucntion to get the user data from the table. Verify that the password is correct.
      @user = User.find_by(email: params[:session][:email].downcase)
    else
      @user = User.find_by(username: params[:session][:email])
    end

    #authenticate is a built in ruby method that returns the user if authenticated correctly.
    if @user && @user.authenticate(params[:session][:password])
      log_in(@user)
      #calls the remember function to remember the user.
      remember @user #this should update the string in the database and
      # place a cookie on the users computer that remembers them.
      flash[:success] = "Welcome to the Sample App!" 
      redirect_to users_path
    else
      flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
      render 'sessions/new'
    end
  end

  def destroy
    #only run log_out if the user is logged in to prevent errors.
  	log_out if logged_in?
  	redirect_to login_path
  end

end
