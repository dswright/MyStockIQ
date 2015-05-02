class UserMailer < ActionMailer::Base
  default from: "noreply@StockIQ.com"

  def invite_mailer(referral_id)
  	@referral = Referral.find(referral_id)
  	mail(to: @referral.email, subject: 'Will you help us build Stock IQ?')
  end
end
