class Newuser < ActiveRecord::Base
	#this class has many built in methods like .new which would create a new user without any methods in here.
	

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

  #confirm that password is encrypted. This riggers a ruby gem called bcrypt.
  has_secure_password

  validates :password, length: { minimum: 6 }

	# Returns the hash digest of the given string.
  def Newuser.digest(string)
  	#sets the cost variable for the bcrypt password function.
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost

    #create a bcrypt password. Necessary since the password is encrypted in the DB.
    BCrypt::Password.create(string, cost: cost)
  end

end
