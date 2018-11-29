require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name:  "",
          email: "user@invalid",
          password:              "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation > div', "The form contains 4 errors."
  end

  test "valid signup information with account activation" do
    #
    # 1. sign-up
    #
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name:  "Example User",
          email: "user@example.com",
          password:              "password",
          password_confirmation: "password"
          }
        }
    end
    user = assigns(:user)
    assert_not user.activated?

    # 1.1. sent activation mail?
    assert_equal 1, ActionMailer::Base.deliveries.size

    # 1.2. required activation information
    follow_redirect!
    assert_template root_path
    assert flash[:info]
    assert_not is_logged_in?

    # 1.3. cannot login before activation
    log_in_as(user)
    assert_not is_logged_in?


    #
    # 2. activation
    #

    # 2.1 failed if invalid token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    # 2.2 failed if valid token but unknwon email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # 2.3 success activation
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
