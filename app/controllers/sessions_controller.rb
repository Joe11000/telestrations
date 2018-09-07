class SessionsController < ApplicationController
  def new
    redirect_to rendezvous_choose_game_type_page_url if current_user
  end

  def create
    @user = User.find_or_create_by(create_params)
    cookies.signed[:user_id] = @user.id if @user
    redirect_to rendezvous_choose_game_type_page_url
    # au = env["omniauth.auth"]
    # cookies.signed[:previous_provider] = au.dig(:provider)
  end

  def destroy
    cookies.signed[:user_id] = ''
    redirect_to root_url
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
