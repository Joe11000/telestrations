class InGameCardUploadsController < ApplicationController
  before_action :set_game
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_playing_game
  before_action :uploaded_card_placeholder

  # r5_wip ->  game#set_up_next_players_turn
  def create
    respond_to do |format|
      format.js do
        begin
          byebug
          if uploaded_card_placeholder.description? && create_params.dig('description_text').present?
            uploaded_card_placeholder.update(description_text: create_params['description_text'], placeholder: false)
          elsif uploaded_card_placeholder.drawing? && create_params.dig('drawing').present?
            uploaded_card_placeholder.update(placeholder: false)
            uploaded_card_placeholder.drawing.attach create_params['drawing']
          else
            head status: "#{uploaded_card_placeholder.medium} card was expected but received #{create_params.keys.first}" and return
          end
        rescue => e
          ActionCable.server.broadcast("game_#{@game.id}", alert: "Upload Unsuccessful. #{e.full_message}")

          render json: { alert: 'error' }  and return
        end

        # set up the placeholder for the next players turn and get params that should be broadcasted to notify users of a card being finished
        @game.set_up_next_players_turn uploaded_card_placeholder

        users_to_send_statuses_to = [current_user, @game.next_player_after(current_user.id) ].compact

        # @broadcast_statuses must stay a instance variable in order to test correctly. setting an expect_to_receive in rspec is difficult because string version pushed into
        @broadcast_statuses = @game.get_status_for_users(users_to_send_statuses_to)
        @broadcast_statuses = @broadcast_statuses.to_json

        ActionCable.server.broadcast("game_#{@game.id}", @broadcast_statuses )

        head :ok  and return
      end
    end

  end

  protected
    def create_params
      params.require(:card).permit(:description_text, :drawing)
    end

    def uploaded_card_placeholder
      @uploaded_card_placeholder ||= Card.get_placeholder_card(current_user.id, @game)
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
