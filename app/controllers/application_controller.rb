class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # force_ssl unless Rails.env.development?

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by_id(cookies.signed[:user_id])
  end

  def logged_in?
    !current_user.blank?
  end

  def redirect_if_not_logged_in
    redirect_to login_url unless logged_in?
  end
end
