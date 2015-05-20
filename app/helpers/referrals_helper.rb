module ReferralsHelper

	def generate_code
		5.times.map{ rand(10) }.join.to_i
	end
end
