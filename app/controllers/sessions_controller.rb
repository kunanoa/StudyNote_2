class SessionsController < ApplicationController

  before_action :require_logout, except: :destroy

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to root_path, success: 'ログインに成功しました'
      Event.logger_info(current_user.name, "ユーザがログインしました")
      DefaultMailer.login(current_user).deliver_now
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
      Event.logger_info("-", "ログインに失敗しました（ email： #{params[:session][:email]} ）")
    end
  end

  def destroy
    Event.logger_info(current_user.name, "ユーザがログアウトしました")
    DefaultMailer.logout(current_user).deliver_now
    log_out
    redirect_to login_path, info: 'ログアウトしました'
  end

  private
  def session_params
    params.require(:session).permit(:email, :password)
  end
  
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
