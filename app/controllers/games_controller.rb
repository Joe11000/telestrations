class GamesController < ApplicationController
  layout 'layouts/game_layout'

  before_action :redirect_if_not_logged_in, except: [:new, :quick_start, :join]

  def new
    current_user.games.create(is_private: params[:privacy] == 'private')

    # open websocket here

    render :new, layout: 'application'
  end

  def start
    @users_waiting = ['person1', 'person2', 'person1', 'person2']

    # @handshake = WebSocket::Handshake::Server.new
  end

  def quick_start
    game = Game.random_open_game
    # @handshake = WebSocket::Handshake::Server.new

    render :start
  end

  def join
    game = Game.where(join_code: join_params)

    if game.blank?
      redirect_to new_game_path, alert: "No players in group #{join_params}" && return
    else
      current_user.games << Game.where(join_code: join_params)
    end

    # let existing members know a new person joined their group
    # @handshake = WebSocket::Handshake::Server.new

    redirect_to start_game_path
  end

  def prevent_additional_players
    # if user is NOT attached to a game, then return false


    @game = Game.find_by(prevent_additional_players_params)

    render alert: "Permission Denied: You are not a member of that group." && return if @game.blank?
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
    Card.all_cards_from_game
  end


protected

  def join_params
    params.require(:join_game)
  end

  def prevent_additional_players_params
    params.require(:id)
  end
end
