# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    unless params['game_id'].blank?
      game = Game.find(params['game_id'])
      stream_from "game_#{params[:game_id]}"
    end
  end

  def unsubscribed
    # stop_all_streams
    # close
  end

  def join_game data_hash
    # debugger
    current_user.assign_player_to_game( params[:game_id], data_hash['users_game_name'] )
    html = render_user_partial_for_game( params[:game_id] )
    ActionCable.server.broadcast("game_#{params[:game_id]}", partial: html)
  end

  def unjoin_game
    cur_game = current_user.current_game
    current_user.leave_current_game
    now_game = current_user.current_game

    html = render_user_partial_for_game( params[:game_id] )
    ActionCable.server.broadcast("game_#{params[:game_id]}", partial: html)

    stop_all_streams
  end

  def start_game
    debugger

  end

  protected

    def render_user_partial_for_game game_id
      users_waiting = Game.all_users_game_names(game_id)
      ApplicationController.render(partial: 'rendezvous/currently_joined', locals: { users_waiting: users_waiting })
    end
end
