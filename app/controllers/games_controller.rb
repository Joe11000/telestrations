require 'json'

class GamesController < ApplicationController
  include ActionController::RequestForgeryProtection

  before_action :redirect_if_not_logged_in
  before_action :set_game, only: [:new, :show]
  before_action :redirect_if_not_playing_game, only: [:new]
  before_action :redirect_if_can_not_view_postgame_page, only: [:show]

  def new
    @game.create_initial_placeholder_if_one_does_not_exist current_user.id

    @data_to_pass_components = @game.get_status_for_user current_user
    @data_to_pass_components[:form_authenticity_token] = form_authenticity_token

    if set_game.cards.count <= 3
      @data_to_pass_components[:back_up_starting_description] = TokenPhrase.generate(' ', numbers: false)
    end

    @data_to_pass_components = @data_to_pass_components.to_json
  end


  def show
    redirect_if_can_not_view_postgame_page
    # @game from redirect method
    @current_user = current_user
    @arr_of_postgame_card_sets = [ @game.cards_from_finished_game ]
  end

  def index
    redirect_if_can_not_view_postgame_page
    # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)
    @current_user = current_user
    @out_of_game_cards = Card.where(out_of_game_card_upload: true, user: current_user)
    @arr_of_postgame_card_sets = current_user.games.map(&:cards_from_finished_game)
  end


  protected
    def redirect_if_not_playing_game
      case @game.try(:status)
      when 'pregame', nil
        redirect_to choose_game_type_page_url and return
      when 'postgame'
        redirect_to postgame_page_url and return
      end
    end

    def redirect_if_can_not_view_postgame_page
      case @game.try(:status)
      when 'pregame', nil
        redirect_to choose_game_type_page_url and return
      when 'midgame'
        redirect_to new_game_url and return
      end
    end

    def set_game
      @game ||= current_user.try(:current_game)
    end
end
