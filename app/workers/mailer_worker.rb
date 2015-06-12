class MailerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  
#Sends referral code invite email to a user
  def perform(referral_id)
    UserMailer.invite_mailer(referral_id).deliver_now
  end
end