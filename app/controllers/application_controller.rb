class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private
    # クエリストリングに含まれるページ番号の取得（正規化込）
    def page_number
      page = params[:page]
      return nil if page.blank?
      return nil unless page.to_s =~ /^[1-9][0-9]*$/

      page = Integer(page)
      return nil if page < 1
      page
    end

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
