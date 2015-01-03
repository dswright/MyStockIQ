class StreamsController < ApplicationController

	#CONFIRM IF THESE ARE STILL NECESSARY AND WHAT OTHER VALIDATIONS THE STREAM MODEL NEEDS.
	
	#First Checks if User is logged in
	before_action :logged_in_user

	before_action :correct_user, only: :destroy

		
end

