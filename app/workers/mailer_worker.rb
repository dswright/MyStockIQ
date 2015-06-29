class MailerWorker
  include Sidekiq::Worker

#Sends referral code invite email to a user
  def perform(referral_id)
    UserMailer.founder_invite_mailer(referral_id).deliver_now
    #UserMailer.invite_mailer(referral_id).deliver_now
  end
end