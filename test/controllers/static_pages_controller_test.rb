require 'test_helper'
require_relative '../helpers/application_helper_test'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = ApplicationHelperTest::Base_title
  end

  test "should get root" do
    get root_path
    assert_response :success
    assert_select "title", @base_title
  end  

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end
end
