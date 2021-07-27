class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def require_login
    unless logged_in?
      redirect_to login_path
    end
  end

  def require_logout
    if logged_in?
      redirect_to root_path
    end
  end

  helper_method :current_user
  helper_method :logged_in?
end
