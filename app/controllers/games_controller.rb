class GamesController < ApplicationController
  layout 'layouts/game_layout'

  before_action :redirect_if_not_logged_in
  before_action :redirect_to_choose_game_type_page #, if Proc.new { current_user.current_game.mid_game? }

  def start_page
    @current_game = current_user.current_game

    if @current_game.pre_game?
      current_user
    end

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
end
