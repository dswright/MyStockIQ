class WaitingusersController < ApplicationController

	def create
		params = waiting_params
    @waiting_user = Waitinguser.new(email:params[:email])
    if @waiting_user.save
    	UserMailer.waitlist_mailer(@waiting_user.id).deliver_now
    	@success = {}
      if params[:source] == "lp"
        @success[:message] = "Thank you for joining our Beta test group! Please check your email for confirmation."
      else
        @success[:message] = "You have successfully signed up for the waitlist! You will hear back from us soon."
	 	  end
    end
		respond_to do |format|
		    format.js {}
		end
	end

	private
		def waiting_params
    	params.require(:waitinguser).permit(:email, :source)
  	end
end
