class ReferralsController < ApplicationController

	before_action :admin_user, only: :new

	def new
	end

	def create
		@referral = Referral.new(referral_params)
		@referral.generate_code

		if @referral.save
		#Send worker to send out invitation email w/ referral code using 'UserMailer' mailer
		MailerWorker.new.perform(@referral.id)
		redirect_to "/referrals"
		else
			redirect_to "/stocks/AAPL"
		end
	end


	private

		def referral_params
			params.require(:referral).permit(:email)
		end

		def admin_user
	      redirect_to(root_url) unless current_user.admin?
	    end

end
