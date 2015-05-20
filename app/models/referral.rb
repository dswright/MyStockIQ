class Referral < ActiveRecord::Base
	belongs_to :inviter, class_name: "User"


	validates :referral_code, presence: true, numericality: true
	validates :inviter_id, presence: true

	#form validation for the email address
  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  	validates :email, length: { maximum: 255 },
              format: { with: VALID_EMAIL_REGEX }


	
	def generate_code
		self.referral_code = 5.times.map{ rand(10) }.join.to_i
	end


end
