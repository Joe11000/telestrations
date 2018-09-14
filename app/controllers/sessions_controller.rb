class SessionsController < ApplicationController
  def new
    redirect_to rendezvous_choose_game_type_page_url if current_user
  end

  def create
    @user = User.find_or_initialize_by(create_params)

    if @user.new_record?
      attach_users_avatar_from_provider @user, provider_avatar_url
    end
    cookies.signed[:user_id] = @user.id if @user
    redirect_to rendezvous_choose_game_type_page_url
  end

  def destroy
    cookies.signed[:user_id] = nil
    redirect_to root_url
  end

  protected

    def create_params
      {
        uid: request.env.dig('omniauth.auth', 'uid'),
        provider: request.env.dig('omniauth.auth', 'provider'),
        name: request.env.dig("omniauth.auth", 'info', 'name').try(:strip)
      }
    end

    def provider_avatar_url
      request.env.dig("omniauth.auth", 'info', 'image')
    end

  private

    def attach_users_avatar_from_provider user, url
      require 'open-uri'
      # open the link
      downloaded_image = open(url)

      # upload via ActiveStorage
      # be careful here! the type may be png or other type!
      user.provider_avatar.attach(io: downloaded_image, filename: 'avatar.jpg', content_type: "image/jpeg")
      user.save
    end
end
