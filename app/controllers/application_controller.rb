class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  require 'rails_autolink'
  require 'uri'

  #give access to these helper files across all controllers.
  include SessionsHelper
  include ReferralsHelper
  
  
end
