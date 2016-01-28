class SessionsController < ApplicationController
  def new
    redirect_to new_game_path if current_user && current_user
  end

  def create
    @user = User.find_or_create_by(create_params)
    session[:user_id] ||= @user.id if @user
    redirect_to new_game_path
  end

  def login_anonymously
    session[:user_id] = User.find_by!(provider: 'Anonymous').id
    byebug
    if session[:user_id].nil?
      redirect_to root_path, alert: 'Sorry. Not currently allowing anonymous users.' && return
    else
      redirect_to new_game_path && return
    end
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
