class UserMailer < ActionMailer::Base

  default from: "StockIQ@mystockiq.com"

  def waitlist_mailer(waiting_user_id)
    @user = Waitinguser.find(waiting_user_id)
    mail(to: @user.email, subject: 'Welcome to StockIQ!', from: "Welcome@mystockiq.com")
  end

  def invite_mailer(referral_id)
  	@referral = Referral.find(referral_id)
  	mail(to: @referral.email, subject: 'Early access to StockIQ')
  end

  def founder_invite_mailer(referral_id)
    @referral = Referral.find(referral_id)
    mail(to: @referral.email, subject: 'Our traders are predicting which stocks are bullish and bearish. Which one do you have?')
  end

  def invite_friends_mailer(user_id)
    @user = User.find(user_id)
    @referral = @user.referrals.first
    mail(to: @user.email, subject: 'What do you think?')
  end

  def welcome_mailer(user_id)
  	@user = User.find(user_id)
    @referral = @user.referrals.first
  	mail(to: @user.email, subject: 'Welcome to StockIQ')
  end

  def follow_mailer(follower_id, followed_id)
  	@follower = User.find(follower_id)
  	@followed = User.find(followed_id)
  	mail(to: @followed.email, subject: "#{@follower.username} followed you on StockIQ")
  end

  def weekly_mailer(user_id) #not yet wired up.
    @user = User.find(user_id)
    @ended_predictions = @user.predictionends.where("predictionends.created_at > ?", Time.zone.now-3600*24*7)
    @live_predictions = @user.predictions.where(active:true)
    unless @ended_predictions.empty? && @live_predictions.empty?
  	  mail(to: @user.email, subject: 'Your Week on StockIQ')
    end
  end

  def predictionend_mailer(predictionend_id)
    @predictionend = Predictionend.find(predictionend_id)
    mail(to: @predictionend.prediction.user.email, subject: "#{@predictionend.prediction.stock.ticker_symbol} Prediction Complete!")
  end

end

