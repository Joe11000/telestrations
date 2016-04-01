class SessionsController < ApplicationController
  def new
    redirect_to rendezvous_choose_game_type_page_path if current_user && current_user
  end

  def create
    @user = User.find_or_create_by(create_params)
    byebug
    cookies.signed[:user_id] ||= @user.id if @user
    session[:user_id] ||= @user.id if @user
    redirect_to rendezvous_choose_game_type_page_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  protected

  def create_params
    {
      uid: request.env['omniauth.auth'].uid,
      provider: request.env['omniauth.auth'].provider,
      name: request.env["omniauth.auth"].info.name.strip,
      provider_avatar: request.env["omniauth.auth"].info.image
    }
  end
end
