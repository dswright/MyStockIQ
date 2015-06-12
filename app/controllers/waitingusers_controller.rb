class WaitingusersController < ApplicationController

	def create
		params = waiting_params
    @waiting_user = Waitinguser.new(email:params[:email])
    if @waiting_user.save
    	@success = {}
      MailerwaitlistWorker.perform_async(@waiting_user.id)
      if params[:source] == "lp"
        @success[:message] = "Thank you for joining StockIQ! Please check your email for confirmation."
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
