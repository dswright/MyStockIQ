require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:sean)
    @stock = stocks(:AAPL)
  end

  should validate_presence_of(:username)
  should validate_length_of(:username).is_at_least(5).is_at_most(25)
  should validate_uniqueness_of(:username)
  should allow_value("WithCapitals").for(:username)

  should validate_presence_of(:email)
  should validate_length_of(:email).is_at_most(255)
  should validate_uniqueness_of(:email)

  should validate_length_of(:password).is_at_least(6)
  should validate_presence_of(:admin)

  should have_many(:stocks)
  should have_many(:comments)
  should have_many(:predictions)
  #should have_many(:prediction_ends)
  should have_many(:likes)
  should have_many(:replies)
  should have_many(:streams)
  should have_many(:referrals)
  should have_many(:followings)


  test "should be valid" do
    assert @user.valid?
  end


  test "username validation should reject invalid usernames" do
    invalid_names = ["like#this}", "orlike$this", "or!!this", ">>>>>>this", "<<<<<<nogood", "()&*%^!@<><>\"mixed", "backslash\n"]
    invalid_names.each do |invalid_name|
      @user.username = invalid_name 
      assert_not @user.valid?, "#{invalid_name.inspect} should be invalid"
    end
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = ["user@example.com", "USER@foo.com", "A_US-ER@foo.bar.org", "first.last@foo.jp", "alice+bob@baz.cn"]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address 
  		assert @user.valid?, "#{valid_address.inspect} should be valid" #use this inspect method to report
  																																	  #on a specific element in the loop
  	end
  end

  test "email validation should reject invalid addresses" do
  	invalid_addresses = ["user@example,com", "user_at_foo.org", "user.name@example.","foo@bar_baz.com", "foo@bar+baz.com", "foo@barbaz..com"]
  	invalid_addresses.each do |invalid_address| #loop through the addresses above using the .each method.
  		@user.email = invalid_address #this makes the user's emaill = to one of the emails above.
  		assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
  	end
  end

  test "should be able to follow a stock" do
    @stock = stocks(:LNKD)
    @user.follow(@stock)
    created_relationship = Relationship.where(follower_id: @user.id, followed_type: "Stock", followed_id: @stock.id)
    assert_not created_relationship.empty?, "User was not able to follow stock"
  end

  test "should be able to unfollow a stock" do
    @user.unfollow(@stock)
    existing = Relationship.where(follower_id: @user.id, followed_type: "Stock", followed_id: @stock.id)
    assert existing.empty?
  end

  test "should be following a stock" do
    assert @user.following?(@stock)
  end

  test "should have followers" do
    assert_not @user.followers.empty?
  end

  test "should have followings" do
    assert_not @user.followings.empty?
  end

  test "should calculate user total score correctly" do
    score = @user.predictions.sum(:score)
    if score > 0
      assert_equal @user.total_score, score, "Total score is calculated incorrectly"
    else 
      assert_equal @user.total_score, 0
    end
  end

  test "should calculate user's stock total score correctly" do
    score = @user.predictions.where(stock_id: @stock.id).sum(:score)
    if score > 0
      assert_equal @user.total_score(@stock), score, "Total score is calculated incorrectly"
    else
      assert_equal @user.total_score(@stock), 0
    end
  end



end
