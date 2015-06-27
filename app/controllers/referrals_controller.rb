class ReferralsController < ApplicationController

	before_action :redirect_non_admin_user, only: [:new, :create]

	def new
	end

	#Referral code generation for admin users only
	def create
		@user = current_user

		#build referral object with email input from form
		@referral = @user.referrals.build(referral_params)

		#If admin already has a referral code, use existing referral code
		if @user.referrals.exists?
			@referral.use_existing_code(@user)
		else			
			@referral.generate_code
		end

		@message = {}
		
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
			params.require(:referral).permit(:email)
		end

end
