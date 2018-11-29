require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    @starter = users(:michael)

    @reseter = users(:archer)
    post password_resets_path, params: { password_reset: { email: @reseter.email } }
    @reset_token = assigns(:user).reset_token
    @reseter.reload

    ActionMailer::Base.deliveries.clear
  end

  test "cannot create reset token if email is blank" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "cannot create password token if email is invalid" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    post password_resets_path, params: { password_reset: { email: "invalid_unknwon@example.com" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "create password token if email is valid" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    post password_resets_path, params: { password_reset: { email: @starter.email } }
    assert_not_equal @starter.reset_digest, @starter.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "start password reset session" do
    get edit_password_reset_path(@reset_token, email: @reseter.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reseter.email
  end

  test "cannot start password reset session if email is invalid" do
    get edit_password_reset_path(@reset_token, email: "")
    assert_redirected_to root_url
  end

  test "cannot start password reset session if user is not activated" do
    @reseter.toggle!(:activated)

    get edit_password_reset_path(@reset_token, email: @reseter.email)
    assert_redirected_to root_url
  end

  test "cannot start password reset session if token is wrong" do
    get edit_password_reset_path('wrong token', email: @reseter.email)
    assert_redirected_to root_url
  end

  test "cannot start password reset settion if expired token" do
    @reseter.update_attribute(:reset_sent_at, 3.hours.ago)

    get edit_password_reset_path(@reset_token, email: @reseter.email)

    patch password_reset_path(@reset_token),
          params: { email: @reseter.email,
                    user: { password:              "foobarbaz",
                            password_confirmation: "foobarbaz" }}
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

  test "start password reset session but failed reset if new password is wrong" do
    get edit_password_reset_path(@reset_token, email: @reseter.email)
    patch password_reset_path(@reset_token),
          params: { email: @reseter.email,
                    user: { password:              "",
                            password_confirmation: "" }}
    assert_select 'div#error_explanation'

    patch password_reset_path(@reset_token),
          params: { email: @reseter.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" }}
    assert_select 'div#error_explanation'
  end

  test "start password reset session and reset password" do
    get edit_password_reset_path(@reset_token, email: @reseter.email)
    patch password_reset_path(@reset_token),
          params: { email: @reseter.email,
                    user: { password:              "foobarbaz",
                            password_confirmation: "foobarbaz" }}

    assert_not_equal @reseter.reset_digest, @reseter.reload.reset_digest
    assert @reseter.reload.reset_digest.nil?
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reseter
  end
end
