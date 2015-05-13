class WaitingusersController < ApplicationController

	def create
		params = waiting_params
    @waiting_user = Waitinguser.new(email:params[:email])
    if @waiting_user.save
    	UserMailer.waitlist_mailer(@waiting_user.id).deliver_now
    	@success = {}
      @success[:message] = "You have successfully signed up for the waitlist! You will hear back from us soon."
	 	end
		respond_to do |format|
		    format.js {}
		end
	end

	private
		def waiting_params
    		params.require(:waitinguser).permit(:email)
  		end
end
