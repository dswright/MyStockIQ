require 'test_helper'

class NewusersFormTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    
    #this starts us off at the signup path page.
    get newusers_path

    #this asserts that there is no difference in the count of users in the  before and
    #after the do action, which posts a user.
    #'Newuser.count' counts the number of users in 'newusers' table, oddly enuf.
    assert_no_difference 'Newuser.count' do  
			#this posts to the newusers path, with the form data in user:. 	
    	post newusers_path, user: { username:  "isnowvalid",  
                             		email: "and now invalid",
                             		password:              "valid10151",
                             		password_confirmation: "valid10151" }
    end
    #make sure that the user ends on the newusers index page.
    assert_template 'newusers/new'
  end

  test "valid signup information" do
    
    #this starts us off at the signup path page.
    get newusers_path
    
    #this asserts that there IS a difference in the count of users before and 
    #after the do action, which posts a user.
    #'Newuser.count' counts the number of users in 'newusers' table, oddly enuf.
    assert_difference 'Newuser.count', 1 do
    
    	#this posts to the newusers path, with the form data in user:. 					
    	post_via_redirect newusers_path, user: { username:  "isnowvalid",  
                             		email: "andnowinvalid@gmail.com",
                             		password:              "valid10151",
                             		password_confirmation: "valid10151" }
    end
    #make sure that the user ends on the newusers index page.
    assert_template 'newusers/new'
    assert is_logged_in?
  end

end