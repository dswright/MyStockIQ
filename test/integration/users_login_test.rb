require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
 
  def setup
	#the users refers to the users.yml file in the fixtures file.
    @user = users(:dylan)
  end

 	test "login with an invalid email" do
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

  test "login with a valid email" do
    #go to the login form page
    get login_path
    #post login variables to the login form
    post login_path, session: { email: @user.email, password: "password" }
    #confirm that the user is now on the login page after logging in.
    assert_redirected_to login_path
    follow_redirect!
    assert_template 'sessions/new'
    #check to confirm that on this page, there is no login link, and that there is a logout link.
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
  end

  test "login with a username input still coming in through the email field." do
    #go to the login form page
    get login_path
    #post login variables to the login form. The hash of login parameters is named 'session'.
    post login_path, session: { email: @user.username, password: "password" }
    #confirm that the user is now on the login page after logging in.
    assert_redirected_to login_path
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
    assert_redirected_to login_path
    follow_redirect!
    assert_template 'sessions/new'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to login_path
    #simulate a user clicking the logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
  end

  #incase someone logs out in one browser and not another
  #The nil digest would be set to nil at logout from the 1st browser.
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

end
