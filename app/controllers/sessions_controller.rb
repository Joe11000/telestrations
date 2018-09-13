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
      uid: request.env.dig('omniauth.auth', 'uid'),
      provider: request.env.dig('omniauth.auth', 'provider'),
      name: request.env.dig("omniauth.auth", 'info', 'name').try(:strip),
      provider_avatar: request.env.dig("omniauth.auth", 'info', 'image')
    }
  end
end


# {"provider"=>"facebook",
#  "uid"=>"10154401235753678",
#  "info"=>
#   {"email"=>"joenoonan27@gmail.com",
#    "name"=>"Joe Noonan",
#    "image"=>"http://graph.facebook.com/v2.10/10154401235753678/picture"},
#  "credentials"=>
#   {"token"=>
#     "EAANt3bcU4e4BAB9l2rXvBpYfZAW8mZBHcG1QFdZCIbjUrheIjhK3KrumdUxnjQkZCwPYewCaObN4ZAi0k4ZBfQNqvuBYb4jyQCAyF6BZBFE8iZBBFLTpaGOD7Me3QcRVVmwNX6AFnRZB78YUVVo8wvfd64PEIgVnA7esZD",
#    "expires_at"=>1541695444,
#    "expires"=>true},
#  "extra"=>
#   {"raw_info"=>
#     {"name"=>"Joe Noonan",
#      "email"=>"joenoonan27@gmail.com",
#      "id"=>"10154401235753678"}}}
