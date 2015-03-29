class UserSettingsController < ApplicationController

  def show
  end

  def update
    user = current_user

    user.email = params[:email]
    user.bio = params[:bio]
    user.image = params[:image]

    #put in password update shit..
    user.save

    redirect_to "/settings"

  end

end
