class User < ActiveRecord::Base

  mount_uploader :image, ImageUploader

  #sets an association that the User will have many comments and predictions associated to it
  has_many :comments
  has_many :predictions
  has_many :predictionends, through: :predictions
  has_many :stocks, through: :predictions
  has_many :likes
  has_many :replies
  has_many :streams, as: :targetable, dependent: :destroy
  has_many :referrals, foreign_key: "inviter_id", dependent: :destroy

  #Foreign key is the default index that would be used. 
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  scope :predictionends, lambda {|user| where(user_id: user.id)}

  #This sets up the relationship such that current_user.followings returns an array of followed objects
  has_many :followings, through: :active_relationships, source: :followed

	#form validation for the username
	before_save { self.email = self.email.downcase } #before inserting the data, make sure it is all downcase.
	before_save { self.username = self.username.downcase } #before inserting the data, make sure it is all downcase.
	validates :username,  presence: true, length: { maximum: 50 },
                    format: { with: /\A[-a-z0-9]+\z/i }, #this doesn't allow numberals. Should fix.
										uniqueness: {case_sensitive: false}
	
	#form validation for the email address
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: {case_sensitive: false}

  #confirm that password is encrypted. This triggers a ruby gem called bcrypt.
  has_secure_password

  validates :password, length: { minimum: 6 }, allow_blank: true

	# Returns the hash digest of the given string.
  def User.digest(string)
  	#sets the cost variable for the bcrypt password function.
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost

    #create a bcrypt password. Necessary since the password is encrypted in the DB.
    BCrypt::Password.create(string, cost: cost)
  end


  #save the remember_digest to the database to match with the user id saved in the user cookie.
  def User.remember(user)
    #create string of characters
    remember_token = SecureRandom.urlsafe_base64
    #set the remember_digest to the encrypted remember_token.
    user.remember_digest = User.digest(remember_token)
    #save the updated user to the database and ignore the validation requirements
    user.save(:validate => false)
    #return the remember_token for putting into the cookie on the controller page.
    return remember_token
  end

  #set the remember_digest to nil.
  def User.forget(user)
    #set the user digest to nil.
    user.remember_digest = nil
    #save the updated user to the database and ignore the validation requirements
    user.save(:validate => false)
  end

  def authenticated?(remember_token)
    #the remember_digest could be nil if the user logs out in 1 browswer and is still logged in in another.
    #return false if the remember_digest is nil.
    return false if remember_digest.nil?
    #compare the remember token in the cookie to the remember_digest in the users table. Not sure how this works.
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #Adds error message in case of invalid sign in
  def invalid_sign_in
    errors[:base] << "Username or password is incorrect."
  end

  def invalid_referral
      errors[:base] << "Referral code is invalid."
  end



  #Follows a user
  def follow(object)
    #sets followed id = other_user id and follower id = user id
    active_relationships.create(followed_id: object.id, followed_type: object.class.name)
  end

  #Unfollows a user
  def unfollow(object)
    #Destroy relationship
    active_relationships.find_by(followed_id: object.id, followed_type: object.class.name).destroy
  end

  #Returns true if the current user is following the other user
  def following?(object)
    active_relationships.find_by(followed_id: object.id, followed_type: object.class.name)
  end

  def followers
    followers = Array.new
    Relationship.where(followed_id: self.id).find_each do |relationship|
      #Assumes User is the only type of follower (Stocks don't follow anyone)
      followers << User.where(id: relationship.follower_id)
    end
    return followers
  end

  def followings
    followings = Array.new
    Relationship.where(follower_id: self.id).find_each do |relationship|
      if relationship.followed_type == "Stock"
        followings << Stock.where(id: relationship.followed_id)
      elsif relationship.followed_type == "User"
        followings << User.where(id: relationship.followed_id)
      end
      #following_ids << relationship.followed_id
    end
    return followings
  end

  def likes_this?(object)
    like_type = object.likes.where(user_id: self.id).first.like_type
    
    if like_type == "like"
      return true
    else 
      return false
    end
  end

  def total_score(stock=nil)

    if stock == nil
      score = self.predictions.sum(:score)
    else
      score = self.predictions.where(stock_id: stock.id).sum(:score)
    end

    #If total score is negative, set total score to zero
    if score < 0
      score = 0
    end

    return score
  end

end
