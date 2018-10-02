class InGameCardUploadsController < ApplicationController
  before_action :set_game
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_playing_game

  def create
    byebug

    respond_to do |format|
      format.js do
        byebug
        if card.description && upload_card_params.dig('description_text').present?
          card.update(description_text: upload_card_params['description_text'])
        elsif card.drawing && upload_card_params.dig('drawing').present?
          card.drawing.attach upload_card_params
        end

        return false if updated_card == false

        # set up the placeholder for the next players turn and get params that should be broadcasted to notify users of a card being finished
        broadcast_params = set_game.set_up_next_players_turn updated_card.id

        set_game.send_out_broadcasts_to_players_after_card_upload broadcast_params

        ActionServer.broadcast("game_#{set_game.id}", partial: 'some partial or js needs to be passed to each user')

        render :nothing and return
      end
    end

  rescue => e
    ActionServer.broadcast("game_#{set_game.id}", alert: "Upload Unsuccessful. #{e.full_message}")

    render :nothing and return
  end

private
  def create_params
    params.require(:card).permit(:description_text, :drawing_image)
  end

  def uploaded_card
    updated_card ||= set_game.try(:upload_info_into_placeholder_card, current_user.id, upload_card_params)
  end

  def redirect_if_not_playing_game
    case @game.try(:status)
    when 'pregame', nil
      redirect_to choose_game_type_page_url and return
    when 'postgame'
      redirect_to postgame_page_url and return
    end
  end

  def set_game
    @game ||= current_user.try(:current_game)
  end

end



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
