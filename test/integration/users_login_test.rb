require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
 
	 def setup
	 	#the newusers refers to the newusers.yml file in the fixtures file.
    @user = newusers(:dylan)
  end

 	test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "", password: "" }
    assert_template 'sessions/new'
    #confirm that an error message gets reported
    assert_not flash.empty?
    get root_path
    #confirm that the error message does not move onto the next page.
    assert flash.empty?
  end

  test "login with valid information" do
    #go to the login form page
    get login_path
    #post login variables to the login form
    post login_path, session: { email: @user.email, password: "password" }
    #confirm that the user is now on the login page after logging in.
    assert_redirected_to newusers_path
    follow_redirect!
    assert_template 'sessions/new'
    #check to confirm that on this page, there is no login link, and that there is a logout link.
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to newusers_path
    follow_redirect!
    assert_template 'sessions/new'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to login_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
  end

end
