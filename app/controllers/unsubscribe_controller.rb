class UnsubscribeController < ApplicationController

  def show
    @disable_nav = true
  end

  def destroy
    @success = {}

    @waiting_user = Waitinguser.find_by(email:params[:email])
    if @waiting_user != nil
      @waiting_user.delete
      @success[:message] = "You have been successfully unsubscribed. We'll miss you!"
    else
      @success[:message] = "This email address cannot be found in our database"
    end

    respond_to do |format|
      format.js {}
    end
  end

end
