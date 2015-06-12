class MailerwaitlistWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :critical

#Sends referral code invite email to a user
  def perform(waiting_user_id)
    UserMailer.waitlist_mailer(waiting_user_id).deliver_now
  end
end