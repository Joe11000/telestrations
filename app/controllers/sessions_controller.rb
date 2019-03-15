require 'open-uri'

class SessionsController < ApplicationController
  # before_action :create_params, only: :create

  def new
    redirect_to choose_game_type_page_url if current_user
  end

  def create
    @user = nil
    
    if form_session_create_params.to_h.all? 
      @user = User.find_or_initialize_by form_session_create_params

      if @user.new_record?
        # attach_anonymous_avatar_to_user @user
        # byebug
        @user.assign_attributes({ uid: (User.count || 0) + 1, provider: nil, name: @user.email })
        @user.save
      end
    elsif omniauth_session_create_params.all?
      puts ("params: #{params.inspect.to_s}!!!!!!!!!!!!!!!!")
      puts ("create_params: #{create_params}!!!!!!!!!!!!!!!!")
      # Rails.logger.info("create_params: #{create_params}!!!!!!!!!!!!!!!!")
      # logger.info @user

      # logger.info "Look Here!!!!!!!"
      # logger.info "params #{params}"
      @user = User.find_or_initialize_by create_params

      if @user.new_record?
        # logger.info "New Record Here!!!!!!!"
        attach_users_avatar_from_provider @user, provider_avatar_url
        @user.save
        puts "saved new person #{@user.name}"
      end
    end


    # logger.info "New Cookie Here!!!!!!!"
    cookies.signed[:user_id] = @user.id if @user
    # logger.info "Redirect Here!!!!!!!"
    redirect_to choose_game_type_page_url
  end

  def destroy
    cookies.signed[:user_id] = nil
    redirect_to root_url
  end

  protected

    def omniauth_session_create_params
      {
        uid: request.env.dig('omniauth.auth', 'uid'),
        provider: request.env.dig('omniauth.auth', 'provider'),
        name: request.env.dig("omniauth.auth", 'info', 'name').try(:strip)
      }
    end

    def provider_avatar_url
      request.env.dig("omniauth.auth", 'info', 'image')
    end

    def form_session_create_params
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

    def attach_users_avatar_from_provider user, url
      # logger.info "attach_users_avatar_from_provider!!!!!!!"
      # open the link

      downloaded_image = open(url)

      # logger.info "opened url #{downloaded_image} !!!!!!!!"
      # upload via ActiveStorage
      # be careful here! the type may be png or other type!
      user.provider_avatar.attach(io: downloaded_image, filename: 'avatar.jpg', content_type: "image/jpeg")
      # logger.info "attached provider_avatar !!!!!"
    end
end
