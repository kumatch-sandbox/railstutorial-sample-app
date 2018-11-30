require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @non_activator = users(:archer)
  end

  test "profile display" do
    get user_path(@user)

    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_select '.microposts_count', "(#{@user.microposts.count.to_s})"
    assert_select 'div.pagination'
    assert_select 'strong#following', text: '2'
    assert_select 'strong#followers', text: '2'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "cannot show profile if non-activated user" do
    get user_path(@non_activator)
    assert_select 'h1', text: @non_activator.name

    @non_activator.update_attribute(:activated, false)
    get user_path(@non_activator)
    assert_redirected_to root_url
  end
end
