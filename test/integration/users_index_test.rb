require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @non_activator = users(:lana)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    users = User.paginate(page: 1)
    assert_select 'ul.users li', count: users.length
    users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path

    assert_template 'users/index'
    assert_select 'a', text: 'delete', count: 0
  end

  test "index ignores non-activated user" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'a[href=?]', user_path(@admin), text: @admin.name
    assert_select 'a[href=?]', user_path(@non_activator), text: @non_activator.name

    @non_activator.update_attribute(:activated, false)
    get users_path
    assert_template 'users/index'
    assert_select 'a[href=?]', user_path(@non_activator), count: 0
  end
end
