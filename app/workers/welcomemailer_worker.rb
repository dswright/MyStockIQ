class WelcomemailerWorker
  include Sidekiq::Worker

#Sends referral code invite email to a user
  def perform(user_id)
    UserMailer.welcome_mailer(user_id).deliver_now
  end
end