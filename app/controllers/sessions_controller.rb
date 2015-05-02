class SessionsController < ApplicationController
  def new
    @disable_nav = true
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

      #uses log_in() method from 'Session Helper'
      log_in @user

      #calls the remember function to remember the user.
      remember @user #this should update the string in the database and
      # place a cookie on the users computer that remembers them.

      render :js => "window.location = '#{user_profile}'"

    else
      @disable_nav = true

      #need blank user object just in case user sign in is invalid
      @user = User.new if @user == nil

      #adds error messages to @user object for invalid sign in
      @user.invalid_sign_in

      respond_to do |format|
        format.js{}
      end
      #redirect_to "/login"
    end
  end

  def destroy
    #only run log_out if the user is logged in to prevent errors.
  	log_out if logged_in?
  	redirect_to login_path
  end

end
