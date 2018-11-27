require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    # 1. get login page
    get login_path
    assert_template 'sessions/new'

    # 2. post login session and failed.
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?

    # 3. move to other page. check flash
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    # 1. get login page
    get login_path

    # 2. post login session and succeed.
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?

    # 3. redirect after login
    assert_redirected_to @user # redirect先の妥当性
    follow_redirect!

    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # 4. logout
    delete logout_path
    assert_not is_logged_in?

    # 5. redirect after logout
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end  
end
