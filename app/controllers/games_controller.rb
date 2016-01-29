class GamesController < ApplicationController
  layout 'layouts/game_layout'

  before_action :redirect_if_not_logged_in, except: [:new, :quick_start, :join]

  def new
    current_user.games.create(is_private: params[:privacy] == 'private')

    render :new, layout: 'application'
  end

  def start
    @users_waiting = []

    if params[:privacy] == 'public'
      @game = Game.create(is_private: false)
    else
      @game = Game.create
    end
  end

  def quick_start

    @game = Game.random_open_game

    if @game.blank?
      redirect_to new_game_path, alert: 'There are no games allowing additional players'
    end

    @users_waiting = @game.users.map(&:users_game_name)

    render :start
  end

  def join
    @game = Game.where(join_code: join_params, allow_additional_players: true)

    if @game.blank?
      redirect_to new_game_path, alert: "No players in group #{join_params}" && return
    else
      @users_waiting = @game.users.map(&:users_game_name)
      render :start && return
    end
  end

  def upload_game_name
    respond_to do |format|
      format.js do
        @game = Game.where(join_code: join_params).active.where( allow_additional_players: true)
        current_user.games << Game.all_users_game_names(params[:join_code]).to_json
        render nothing: true
      end
    end
  end

  def all_game_names
    render js: Game.all_users_game_names(params[:join_code]).to_json
  end

  def leave_group
    # close down socket for retreving push notifications
     # delete groupuser association.

     # if no other players in group
     #   then update others that current player is leaving
     #   else no need up update anyone, just hard delete the game down.


    redirect_to new_game_path
  end

  def post_game
    @cards = Card.all_cards_from_game
  end



protected
  def create_game_name_params
    params.require(:name, :join_code)
  end

  def join_params
    params.require(:join_game)
  end

  def prevent_additional_players_params
    params.require(:id)
  end
end
