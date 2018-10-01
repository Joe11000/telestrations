class InGameCardUploadsController < ApplicationController
end


  # before_action :redirect_if_not_logged_in
  # before_action :set_game, only: [:new, :show]
  # before_action :redirect_if_not_playing_game, only: [:new]

  # def new
  # end

  # def create
  #   begin
  #     create_params[:drawings].each do |drawing|
  #       Card.create(uploader_id: current_user.id, medium: 'drawing', drawing: drawing, out_of_game_card_upload: true)
  #     end
  #     # flash[:notice] = %(Successfully Uploaded #{create_params[:drawings].length} #{'Image'.pluralize(create_params[:drawings].length)}. <a href=#{all_postgames_page_path}>View Uploaded Drawings</a> )
  #     # redirect_to(action: :new) and return
  #   rescue => e
  #     flash[:alert] = "Upload Unsuccessful. #{e.full_message}"
  #     redirect_to(action: :new) and return
  #   end
  # end

  # def redirect_if_not_playing_game
  #   byebug

  #     case @game.try(:status)
  #     when 'pregame', nil
  #       redirect_to choose_game_type_page_url and return
  #     when 'postgame'
  #       redirect_to postgame_page_url and return
  #     end
  #   end

  #   def set_game
  #     @game ||= current_user.try(:current_game)
  #   end
