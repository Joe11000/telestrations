class GamesController < ApplicationController

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_can_not_view_game_page, if: :game_page
  before_action :redirect_if_can_not_view_postgame_page, if: :postgame_page

  def game_page
    set_game
    # @game from redirect method
    @placeholder_card = @game.get_placeholder_card current_user.id
    @player_is_finished = false

    # create a starting placeholder card for this user if game is just beginning
    if( @placeholder_card.blank? && current_user.current_starting_card.blank? )
      byebug
      @placeholder_card = @game.create_initial_placeholder_for_user current_user.id
    end


    #  is the user done or waiting for others to pass him a card
    if( @placeholder_card.blank?)
      byebug

      # get array
        passing_array = current_user.current_game.parse_passing_order
      # find my position before mine in array

        prev_user_index_in_passing_order = passing_array.index(current_user.id) - 1
        prev_user_index_in_passing_order = passing_array.last if prev_user_index_in_passing_order < 0

      # is gu from completed?
      @player_is_finished = GamesUser.where(user_id: passing_array[prev_user_index_in_passing_order], game: current_user.current_game).order(:id).last.set_complete
    end


    byebug
    @prev_card = @placeholder_card.try(:parent_card) || Card.none
    @current_user = current_user
    render 'game_page'
  end

  def postgame_page
    # @game from redirect method
    @current_user = current_user
    @arr_of_postgame_card_sets = [ @game.cards_from_finished_game ]
  end

  def all_postgames_page
    # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)
    @current_user = current_user
    @out_of_game_cards = Card.where(out_of_game_card_upload: true, user: current_user)
    @arr_of_postgame_card_sets = current_user.games.map(&:cards_from_finished_game)
  end


  protected
    def redirect_if_can_not_view_game_page
      set_game

      case @game.try(:status)
      when 'pregame', nil
        redirect_to rendezvous_choose_game_type_page_url
      when 'postgame'
        redirect_to postgame_page_url
      end
    end

    def redirect_if_can_not_view_postgame_page
      set_game

      case @game.try(:status)
      when 'pregame', nil
        redirect_to rendezvous_choose_game_type_page_url
      when 'midgame'
        redirect_to game_page_url
      end
    end

    def set_game
      @game ||= current_user.try(:current_game)
    end
end
