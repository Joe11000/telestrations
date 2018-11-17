class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl if Rails.env.production?

  helper_method :current_user, :logged_in?, :get_drawing_url

  def current_user
    @current_user ||= User.find_by_id(cookies.signed[:user_id])
  end

  def logged_in?
    !current_user.blank?
  end

  def redirect_if_not_logged_in
    redirect_to login_url unless logged_in?
  end

  include Rails.application.routes.url_helpers

  def get_drawing_url card
    byebug
    unless (card.drawing? && card.drawing.attached?)
      raise 'Card must be a drawing with an image attached'
    end

    return rails_blob_path(card.drawing, disposition: 'attachment')
  end
end
