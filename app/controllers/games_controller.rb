class GamesController < ApplicationController
  # layout 'layouts/game'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_no_current_game, except: [:postgame]

  def game_page
    @game = current_user.current_game
    @placeholder_card = @game.find_or_create_placeholder_card current_user.id
    @prev_card = @placeholder_card.try(:parent_card)

    # @variable = 'Playing Game'
  end

  def postgame
    # redirect_to game_page_path unless current_user.current_game.status == 'postgame'
    # @cards = Card.all_cards_from_game
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
