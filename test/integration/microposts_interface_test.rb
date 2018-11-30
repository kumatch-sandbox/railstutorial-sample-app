require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'

    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'

    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: 'a' * 141 } }
    end
    assert_select 'div#error_explanation'


    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')

    assert_difference 'Micropost.count', 1 do
      post microposts_path,
           params: {
               micropost: {
                   content: content,
                   picture: picture,
               }}
    end
    assert assigns(:micropost).picture?
    assert_redirected_to root_url


    follow_redirect!
    assert_match content, response.body

    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end


  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_select '.user_info_micropost_count', "#{34} microposts" # fixture に 34 posts の定義あり

    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_select '.user_info_micropost_count', "0 microposts"
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_select '.user_info_micropost_count', "1 micropost"
  end
end