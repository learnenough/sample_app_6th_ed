require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  class RestFormTest < ActionDispatch::IntegrationTest

    def setup
      @user = users(:michael)
    end

    test "invalid email" do
      post password_resets_path, params: { password_reset: { email: "" } }
      assert_not flash.empty?
      assert_template 'password_resets/new'
    end

    test "valid email" do
      post password_resets_path,
           params: { password_reset: { email: @user.email } }
      assert_not_equal @user.reset_digest, @user.reload.reset_digest
      assert_equal 1, ActionMailer::Base.deliveries.size
      assert_not flash.empty?
      assert_redirected_to root_url
    end
  end

  class ResetSubmissionTest < ActionDispatch::IntegrationTest

    def setup
      post password_resets_path,
           params: { password_reset: { email: users(:michael).email } }
      @user = assigns(:user)
    end

    test "wrong email" do
      get edit_password_reset_path(@user.reset_token, email: "")
      assert_redirected_to root_url
    end

    test "inactive user" do
      @user.toggle!(:activated)
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      assert_redirected_to root_url
    end

    test "right email, wrong token" do
      get edit_password_reset_path('wrong token', email: @user.email)
      assert_redirected_to root_url
    end

    test "right email, right token" do
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      assert_template 'password_resets/edit'
      assert_select "input[name=email][type=hidden][value=?]", @user.email
    end

    test "invalid password & confirmation" do
      patch password_reset_path(@user.reset_token),
            params: { email: @user.email,
                      user: { password:              "foobaz",
                              password_confirmation: "barquux" } }
      assert_select 'div#error_explanation'
    end

    test "empty password" do
      patch password_reset_path(@user.reset_token),
            params: { email: @user.email,
                      user: { password:              "",
                              password_confirmation: "" } }
      assert_select 'div#error_explanation'
    end

    test "valid password & confirmation" do
      patch password_reset_path(@user.reset_token),
            params: { email: @user.email,
                      user: { password:              "foobaz",
                              password_confirmation: "foobaz" } }
      assert is_logged_in?
      assert_not flash.empty?
      assert_redirected_to @user
    end
  end
end
