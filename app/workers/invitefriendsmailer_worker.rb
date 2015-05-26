class InvitefriendsmailerWorker
  include Sidekiq::Worker

#Sends referral code invite email to a user
  def perform(user_id)
    UserMailer.invite_friends_mailer(user_id).deliver_later
  end
end