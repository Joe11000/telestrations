class GamesController < ApplicationController
  # layout 'layouts/game'

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_can_not_view_game_page, only: :game_page
  before_action :redirect_if_can_not_view_postgame_page, only: :postgame_page

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

  def postgame_page
    # @game from redirect method
    @current_user = current_user
    @arr_of_postgame_card_sets = [ @game.cards_from_finished_game ]
  end

  def all_postgames_page
    # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)

    @current_user = current_user
    @arr_of_postgame_card_sets = current_user.games.map(&:cards_from_finished_game)
  end


  protected
    def redirect_if_can_not_view_game_page
      @game = current_user.try(:current_game)

      case @game.try(:status)
      when 'pregame', nil
        redirect_to rendezvous_choose_game_type_page_path
      when 'postgame'
       redirect_to postgame_page_path
      end
    end

    def redirect_if_can_not_view_postgame_page
      @game = current_user.try(:current_game)

      case @game.try(:status)
      when 'pregame', nil
        redirect_to rendezvous_choose_game_type_page_path
      when 'midgame'
       redirect_to game_page_path
      end
    end

end
