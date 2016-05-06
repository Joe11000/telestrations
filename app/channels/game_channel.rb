# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    if params['join_code']
      game = Game.find_by(join_code: params['join_code'])
      stream_from "game_#{params[:join_code]}"
    end
  end

  def unsubscribed
    # stop_all_streams
    # close
  end

  def join_game data_hash
    current_user.assign_player_to_game( params[:join_code], data_hash['users_game_name'] )
    html = render_user_partial_for_game( params[:join_code] )
    ActionCable.server.broadcast("game_#{params[:join_code]}", partial: html)
  end

  def unjoin_game
    cur_game = current_user.current_game
    debugger
    current_user.leave_current_game
    now_game = current_user.current_game
    debugger


    html = render_user_partial_for_game( params[:join_code] )
    ActionCable.server.broadcast("game_#{params[:join_code]}", partial: html)
    debugger

    stop_all_streams
  end

  def start_game
    debugger

  end

  protected

    def render_user_partial_for_game join_code
      users_waiting = Game.all_users_game_names(join_code)
      ApplicationController.render(partial: 'rendezvous/currently_joined', locals: { users_waiting: users_waiting })
    end
end
