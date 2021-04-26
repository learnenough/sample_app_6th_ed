require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  def login_as(user)
    get login_path
    post login_path, params: { 
      session: { email: user.email, password: 'password' } 
    }
  end

  test "profile display while anonyomus" do
    get user_path(@user)
    assert_equal 200, response.status
    # assert_match URI.parse(response.location).path, "/login"
  end

  <<~LOGGED_IN_USER
  test "profile display while logged in as the user" do
    login_as @user

    get user_path(@user)
    assert_equal 200, response.status
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
  LOGGED_IN_USER

  <<~OTHER_USER
  test "profile display while logged in as someone else" do
    login_as @other_user

    get user_path(@user)
    assert_equal 302, response.status
    assert_match URI.parse(response.location).path, "/login"
  end
  OTHER_USER
end
