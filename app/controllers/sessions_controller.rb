require 'open-uri'

class SessionsController < ApplicationController
  before_action :create_params, only: :create

  def new
    redirect_to choose_game_type_page_url if current_user
  end

  def create
    @user = nil
    
    # if form_session_create_params.to_h.all? 
    if create_params.to_h.all? 
      @user = User.find_or_initialize_by create_params

      @user.save if @user.new_record?
    end

    cookies.signed[:user_id] = @user.id if @user
    redirect_to choose_game_type_page_url
  end

  def destroy
    cookies.signed[:user_id] = nil
    redirect_to root_url
  end

  protected

    def provider_avatar_url
      request.env.dig("omniauth.auth", 'info', 'image')
    end

    def create_params
    # def form_session_create_params
      params.require('user').permit(:email, :password_digest)
    end

  private

    # def attach_anonymous_avatar_to_user user
    #   user.provider_avatar.attach(io: open(get_anonymous_image_from_public_folder), filename: 'anonymous.png', content_type: "image/png")
    # end

    # def get_anonymous_image_from_public_folder
    #   file_glob_search = Rails.public_path + 'assets/anony*'
    #   Dir[file_glob_search].first
    # end

    # def attach_users_avatar_from_provider user, url
    #   downloaded_image = open(url)
    #   user.provider_avatar.attach(io: downloaded_image, filename: 'avatar.jpg', content_type: "image/jpeg")
    # end
end
