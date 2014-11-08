require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup #This 'User' class create a mock user with these attributes for this test.
  	#the test works by running '.new' on the Newuser model, which is a default command.
  	#the password and password_confirmation are not actual columns. This password is confirmed to be the same,
  	#and then inserted into the column 'password_digest' in the users table by the bcrypt gem.
    @user = User.new(username: "ExampleUser", email: "something@gmail.com",
    										password: "foobar", password_confirmation: "foobar")
  end

#the test then checks to see if this is valid.
  test "should be valid" do
    assert @user.valid?
  end

#this sets the user.name to an invalid value, 
#and then checks to see if the @user is invalid, based on the validations in the model
  test "name should be present" do
    @user.username = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.username = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 256
    assert_not @user.valid?
  end

  test "username should accept valid names only" do
    valid_addresses = ["dylanwright", "WithCapitals"]
    #loop through the addresses above using the .each method.
    valid_addresses.each do |valid_username|
      #this makes the user's emaill = to one of the emails above.
      @user.username = valid_username
      #use this inspect method to report on a specific element in the loop
      assert @user.valid?, "#{valid_username.inspect} should be valid"
                                                                    
    end
  end

  test "username validation should reject invalid usernames" do
    invalid_addresses = ["like#this}", "orlike$this", "or!!this",
                           ">>>>>>this", "<<<<<<nogood", "()&*%^!@<><>\"mixed", "backslash\n"]
    invalid_addresses.each do |invalid_username| #loop through the addresses above using the .each method.
      @user.username = invalid_username #this makes the user's emaill = to one of the emails above.
      assert_not @user.valid?, "#{invalid_username.inspect} should be invalid"
    end
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = ["user@example.com", "USER@foo.com", "A_US-ER@foo.bar.org", 
  										 "first.last@foo.jp", "alice+bob@baz.cn"]
  	valid_addresses.each do |valid_address| #loop through the addresses above using the .each method.
  		@user.email = valid_address #this makes the user's emaill = to one of the emails above.
  		assert @user.valid?, "#{valid_address.inspect} should be valid" #use this inspect method to report
  																																	  #on a specific element in the loop
  	end
  end

  test "email validation should reject invalid addresses" do
  	invalid_addresses = ["user@example,com", "user_at_foo.org", "user.name@example.",
                           "foo@bar_baz.com", "foo@bar+baz.com", "foo@barbaz..com"]
  	invalid_addresses.each do |invalid_address| #loop through the addresses above using the .each method.
  		@user.email = invalid_address #this makes the user's emaill = to one of the emails above.
  		assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
  	end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup  #dup the @user, ie michael hartl.
    duplicate_user.email = @user.email #set the email of duplicate user = to @user.email
    @user.save #save michael hartl into the databse.
    assert_not duplicate_user.valid? #make sure that the duplicate user is not valid.
  end

    test "usernames should be unique too!" do
    duplicate_user = @user.dup  #dup the @user, ie michael hartl.
    duplicate_user.username = @user.username #set the username of duplicate user = to @user.username
    @user.save #save original user into the databse.
    assert_not duplicate_user.valid? #make sure that the duplicate user is not valid.
  end

#makes both password and confirm password to 5 chars and checks for validity.
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end


end
