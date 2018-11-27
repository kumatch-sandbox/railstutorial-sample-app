require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  Base_title = "Ruby on Rails Tutorial Sample App"

  test "full title helper" do
    assert_equal full_title,         Base_title
    assert_equal full_title("Help"), "Help | #{Base_title}"    
  end
end
