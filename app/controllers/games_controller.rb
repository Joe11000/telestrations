class GamesController < ApplicationController
  layout 'layouts/game'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_no_current_game, except: [:postgame]

  def game_page
    # @variable = 'Playing Game'
    @game = current_user.current_game
  end

  def postgame
    # redirect_to game_page_path unless current_user.current_game.is_postgame?
    # @cards = Card.all_cards_from_game
  end

  # params[:]
  def upload_card
    byebug
    render 200
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
