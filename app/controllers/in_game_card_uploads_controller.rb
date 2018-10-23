class InGameCardUploadsController < ApplicationController
  before_action :set_game
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_playing_game
  before_action :uploaded_card_placeholder

  def create
    byebug
    respond_to do |format|
      format.js do

        # byebug
        if uploaded_card_placeholder.description? && create_params.dig('description_text').present?
          # byebug
          uploaded_card_placeholder.update(description_text: create_params['description_text'])
        elsif uploaded_card_placeholder.drawing? && create_params.dig('drawing_image').present?
          # byebug
          uploaded_card_placeholder.drawing.attach create_params
        end

        if !uploaded_card_placeholder.valid? || uploaded_card_placeholder.changed? # updated card should be valid and all changes persisted, otherwise something is weird and this should bail
          # byebug
          head status: 'updated card should be valid and all changes persisted at this point. Something is weird and bailing'  and return
        end

        # byebug
        # set up the placeholder for the next players turn and get params that should be broadcasted to notify users of a card being finished
        broadcast_params = @game.set_up_next_players_turn uploaded_card_placeholder.id

        @game.send_out_broadcasts_to_players_after_card_upload broadcast_params

        ActionCable.server.broadcast("game_#{@game.id}", partial: 'some partial or js needs to be passed to each user')

        head :ok  and return
      end
    end

  rescue => e
    ActionCable.server.broadcast("game_#{@game.id}", alert: "Upload Unsuccessful. #{e.full_message}")

    render json: {alert: 'error'}  and return
  end

  protected
    def create_params
      params.require(:card).permit(:description_text, :drawing_image)
    end

    def uploaded_card_placeholder
      @uploaded_card_placeholder ||= @game.get_placeholder_card current_user.id
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
