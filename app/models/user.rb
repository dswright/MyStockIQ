class User < ActiveRecord::Base
	#this class has many built in methods like .new which would create a new user without any methods in here.
	
	#we need to add a new 

	#form validation for the username
	before_save { self.email = self.email.downcase } #before inserting the data, make sure it is all downcase.
	before_save { self.username = self.username.downcase } #before inserting the data, make sure it is all downcase.
	validates :username,  presence: true, length: { maximum: 50 }, 
										uniqueness: {case_sensitive: false}
	
	#form validation for the email address
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: {case_sensitive: false}

  #confirm that password is encrypted. This triggers a ruby gem called bcrypt.
  has_secure_password

  validates :password, length: { minimum: 6 }

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

end
