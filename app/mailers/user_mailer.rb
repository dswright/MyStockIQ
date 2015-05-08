class UserMailer < ActionMailer::Base

  default from: "hello@mystockiq.com"

  def waitlist_mailer(user_id)
  	@user = User.find(user_id)
  	mail(to: @user.email, subject: 'StockIQ beta group')
  end

  def invite_mailer(referral_id)
  	@user = User.find(user_id)
  	@referral = Referral.find(referral_id)
  	mail(to: @referral.email, subject: 'Early access to StockIQ')
  end

  def welcome_mailer(user_id)
  	@user = User.find(user_id)
  	mail(to: @user.email, subject: 'Welcome to StockIQ')
  end

  def follow_mailer(follower_id, followed_id)
  	@user = User.find(user_id)
  	@follower = User.find(follower_id)
  	@followed = User.find(followed_id)
  	mail(to: @followed.email, subject: "#{@follower.username} followed you on StockIQ")
  end

  # def close_mailer(follower_id, followed_id)
  # 	@follower = User.find(follower_id)
  # 	@followed = User.find(followed_id)
  # 	mail(to: @followed.email, subject: '#{@follower.username} followed you on StockIQ')
  # end

end


