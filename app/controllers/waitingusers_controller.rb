class WaitingusersController < ApplicationController

  def create

    waiting_user = Waitinguser.new(email:params[:email])
    if waiting_user.save
      @response = ""
    respond_to do |format|
      format.js {}
    end

  end

end
