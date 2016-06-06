class GamesController < ApplicationController
  # layout 'layouts/game'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_can_not_view_game_page, only: :game_page

  def game_page
    # @game from redirect method
    @placeholder_card = @game.get_placeholder_card current_user.id

    # create a starting placeholder card for this user if game is just beginning
    if( @placeholder_card.blank? && current_user.starting_card_in_current_game.blank? )
      @placeholder_card = @game.create_initial_placeholder_for_user current_user.id
    end

    @prev_card = @placeholder_card.try(:parent_card) || Card.none
    @current_user = current_user
  end

  def postgame
    @game = current_user.current_game

    case @game.status
      when 'pregame' then redirect_to rendezvous_choose_game_type_page_path
      when 'midgame' then redirect_to game_page_path
    end

    @cards = Card.all_cards_from_game
  end

  protected
    def redirect_if_can_not_view_game_page
      @game = current_user.try(:current_game)

      case @game.try(:status)
      when 'pregame', nil
        redirect_to rendezvous_choose_game_type_page_path
      when 'postgame'
       redirect_to postgame_path
      end
    end
end
