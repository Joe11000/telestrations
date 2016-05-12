class GamesController < ApplicationController
  # layout 'layouts/game_layout'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_no_current_game

  def start_page
    # @variable = 'Playing Game'
    # @current_game = current_user.current_game
  end

  def start

    # revise similar code here in start action
    # respond_to do |format|
    #   format.js do
    #     current_game = current_user.current_game
    #     unless current_game.blank?
    #       @game = Game.pre_game.where(join_code: params[:join_code])

    #       current_user.games << Game.all_users_game_names(@game.id).to_json
    #       render status: 200 && return
    #     end

    #     render status: 401 && return
    #   end
    # end
  end

  def post_game
    @cards = Card.all_cards_from_game
  end

  protected
    def create_game_name_params
      params.require(:name, :join_code)
    end

    def prevent_additional_players_params
      params.require(:id)
    end

    def redirect_if_no_current_game
      redirect_to rendezvous_choose_game_type_page_path if current_user.current_game.try(:status) != 'midgame'
    end
end
