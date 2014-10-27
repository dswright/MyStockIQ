class SessionsController < ApplicationController
  def new
  end

   def create
   	#use find_by fucntion to get the user data from the table. Verify that the password is correct.
    @user = Newuser.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in(@user)
      flash[:success] = "Welcome to the Sample App!" 
      redirect_to newusers_path
    else
      flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
      render 'sessions/new'
    end
  end

  def destroy
  	log_out
  	redirect_to login_path
  end

end
