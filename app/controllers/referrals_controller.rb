class ReferralsController < ApplicationController

	before_action :admin_user, only: :new

	def new
		@user = current_user

		@referral = @user.referrals.build
	end

	def create
		@user = current_user

		@referral = @user.referrals.build(referral_params)
		@referral.generate_code

		@message = {success: ""}
		
		if @referral.save
			#Send worker to send out invitation email w/ referral code using 'UserMailer' mailer
			MailerWorker.new.perform(@referral.id)
			@message[:success] = "Invite referral sent!"
		end
 	

		respond_to do |f|
			f.js
		end

	end


	private

		def referral_params
			params.require(:referral).permit(:email, :inviter_id)
		end

		def admin_user
			return if user_logged_in?
      		redirect_to(root_url) unless current_user.admin?
    	end

end
