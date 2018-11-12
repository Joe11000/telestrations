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
    @current_user = current_user
    @game = current_user.games.order(:id).try(:last)

    (redirect_to choose_game_type_page_path and return) if @game.blank?
    @arr_of_postgame_card_sets = [ Card.cards_from_finished_game(@game.id) ]
  end

  def index
    # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)
    @current_user = current_user
    @out_of_game_cards = Card.where(out_of_game_card_upload: true, user: current_user)

    @arr_of_postgame_card_sets = Card.cards_from_finished_games(current_user.games.postgame.ids)
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
