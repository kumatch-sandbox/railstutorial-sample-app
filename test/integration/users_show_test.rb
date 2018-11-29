require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @non_activator = users(:archer)
  end

  test "show user" do
    get user_path(@user)
    assert_select 'h1', text: @user.name
  end

  test "show failed if non-activated user" do
    get user_path(@non_activator)
    assert_select 'h1', text: @non_activator.name

    @non_activator.update_attribute(:activated, false)
    get user_path(@non_activator)
    assert_redirected_to root_url
  end

end
