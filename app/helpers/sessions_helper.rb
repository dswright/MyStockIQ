module SessionsHelper

# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    #get the remember token returned from the database input method.
    remember_token = User.remember(user)
    #save an encryted user.id to the user cookies.
    cookies.permanent.signed[:user_id] = user.id
    #save an unencrypted remember_token to the user cookies.
    cookies.permanent[:remember_token] = remember_token
  end


  def forget(user)
    User.forget(user)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Returns the current logged-in user (if any).
  def current_user
    #if the session[user_id] is present, set it = to user_id
    if (user_id = session[:user_id])
      #set the current user = to the user with this user id.
      @current_user ||= User.find_by(id: user_id)
    #if the cookies.signed[user_id] is present, set it equal to user_id.
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      #if the user id is valid, and aligns with the authentication cookie in the database, then login the user.
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def current_user?(user)
    user == current_user
  end
  
  def logged_in?
    !current_user.nil?
  end

  def user_logged_in?
    unless logged_in?
      redirect_to login_url
      return true
    end
  end

  def log_out
    #forget the current user by deleting their cookies and setting the remember_digest to nil.
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  #Path to user profile page
  def user_profile
    "/users/#{current_user.username}/"
  end

  def user_path(user)
    "/users/#{user.username}/"
  end

end
