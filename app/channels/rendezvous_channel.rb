# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class RendezvousChannel < ApplicationCable::Channel
  include Rails.application.routes.url_helpers

  def subscribed
    unless params['join_code'].blank? || Game.find_by(join_code: params['join_code']).blank?
      stop_all_streams
      stream_from "rendezvous_#{params[:join_code]}"
      current_user.rendezvous_with_game(params[:join_code])
    end
  end

  def unsubscribed
    # stop_all_streams
    # close
  end

  def join_game data_hash
    current_user.commit_to_game( params[:join_code], data_hash['users_game_name'] )
    html = render_user_partial_for_game( params[:join_code] )
    ActionCable.server.broadcast("rendezvous_#{params[:join_code]}", partial: html)
  end

  def unjoin_game
    current_user.leave_current_game

    html = render_user_partial_for_game( params[:join_code] )
    ActionCable.server.broadcast("rendezvous_#{params[:join_code]}", partial: html)
    # debugger
    stop_all_streams
  end

  def start_game
    game = Game.find_by(join_code: params[:join_code])
    # debugger

    return if game.blank?
    # debugger

    game.update(status: 'midgame', join_code: nil)

    # remove user games_users association to people that didn't submit a name
    game.unassociated_rendezousing_games_users.destroy_all

    # broadcast a message to try and go to the game start page. The before action will allow the commited people through to their game and send the uncommited people back to the game choice page.
    ActionCable.server.broadcast("rendezvous_#{params[:join_code]}", start_game_signal: game_page_path)
    # debugger
  end

  protected

    def render_user_partial_for_game join_code
      users_waiting = Game.all_users_game_names(join_code)
      ApplicationController.render(partial: 'rendezvous/currently_joined', locals: { users_waiting: users_waiting })
    end
end
