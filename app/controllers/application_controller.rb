class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  #these have to be included in this file to have access to the helper files in the controller.
  include SessionsHelper
  include StocksHelper
  include CommentsHelper
<<<<<<< Updated upstream
  include StreamsHelper
=======
  include PredictionsHelper
>>>>>>> Stashed changes
  
  private


  	#Confirms logged in user. Used in both 'Users' and 'Streams controllers'
  	def logged_in_user
  		unless logged_in?
  			flash[:danger] = "Please log in."
  			redirect_to login_url
  		end
  	end
end
