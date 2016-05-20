class GamesController < ApplicationController
  # layout 'layouts/game'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_no_current_game, except: [:postgame]

  def game_page
    @card = Card.last
    # @variable = 'Playing Game'
    @game = current_user.current_game
  end

  def postgame
    # redirect_to game_page_path unless current_user.current_game.is_postgame?
    # @cards = Card.all_cards_from_game
  end

  # params[:]
  def upload_card
    respond_to do |format|
      format.js do
        byebug;
        a = Card.make_unsaved_card_from_data_uri(params.slice(:filename, :data))
        a.drawing_or_description = 'drawing'
        a.save
        byebug
       end

      format.html {byebug}
    end
    #
    render status: 200
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
