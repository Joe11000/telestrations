class GamesController < ApplicationController
  include ActionController::RequestForgeryProtection
  # include ActiveStorageUrlCreater

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
    # if user inputs params[:id] == 0, then user doen't know their last postgame and wants to view it.
    if params[:id] == 0
      params[:id] = current_user.games.postgame.last
    end

    respond_to do |format|
      format.js do

        game = current_user.games.postgame.find(params[:id])
        @postgame_component_params = AssemblePostgamesComponentParams.new(current_user: current_user, game: game).result_to_json

        if @game.present?
          render( json: [ Card.cards_from_finished_game(@game.id) ] ) and return
        else
          render( json: { error: 'User can not see game, because they did not play in that game' } ) and return
        end
      end
    end
  end

  def index
    # current_user_postgames = current_user.games.postgame
    # (redirect_to(choose_game_type_page_path) and return) if current_user_postgames.blank?

    # last_postgame = current_user_postgames.last

    # @postgame_component_params = AssemblePostgamesComponentParams.new(current_user: current_user, game: last_postgame).result_to_json
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
