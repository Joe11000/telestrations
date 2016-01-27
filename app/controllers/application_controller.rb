class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # force_ssl unless Rails.env.development?

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    current_user != nil
  end

  def is_user_anonymous?
    logged_in? && session[:user_id] == User.find_by!(provider: 'Anonymous').try(:id)
  end
end
