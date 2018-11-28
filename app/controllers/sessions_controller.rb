class SessionsController < ApplicationController
  def new
  end

  def create
    p = session_params
    user = User.find_by(email: p[:email])
    if user && user.authenticate(p[:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password.' # flash.now で同期描写したら即時フラッシュ
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
    def session_params
      params.require(:session).permit(:email, :password)
    end
end
