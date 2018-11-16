class GamesController < ApplicationController
  include ActionController::RequestForgeryProtection

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_playing_game, only: [:new]

  def new
    @game.create_initial_placeholder_if_one_does_not_exist current_user.id

    @game_component_params = AssembleGamesComponentParams.new({current_user: current_user,
                                                               form_authenticity_token: form_authenticity_token,
                                                               game: @game}).result_to_json
  end

  # @game from redirect method
  def show
    # @current_user = current_user
    # @game = current_user.games.order(:id).try(:last)

    respond_to do |format|
      # format.html do
      #   if @game.blank?
      #     ( redirect_to(choose_game_type_page_path, alert: 'User can not see game, because they did not play in that game') and return)
      #   end

      #   @arr_of_postgame_card_sets = [ Card.cards_from_finished_game(@game.id) ]
      # end

      format.js do
        game_id = current_user.games.postgame.find(params[:id])
        @postgame_component_params = AssemblePostgamesComponentParams.new(current_user: current_user, game_id: game_id).result_to_json

        if @game.present?
          render( json: [ Card.cards_from_finished_game(@game.id) ] ) and return
        else
          render( json: { error: 'User can not see game, because they did not play in that game' } ) and return
        end
      end
    end
  end

  def index
    current_user_postgames = current_user.games.postgame
    (redirect_to(choose_game_type_page_path) and return) if current_user_postgames.blank?

    last_postgame_id = current_user_postgames.last.id
    @postgame_component_params = AssemblePostgamesComponentParams.new(current_user: current_user,
                                                                      game_id:      last_postgame_id).result
  end

  protected
    def redirect_if_not_playing_game
      case set_game_for_action_new_method.try(:status)
      when 'pregame', nil
        redirect_to choose_game_type_page_path and return
      end
    end

    def set_game_for_action_new_method
      @game ||= current_user.current_game
    end
end
