# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class LobbyChannel < ApplicationCable::Channel
  include Rails.application.routes.url_helpers

  def subscribed
    kill_switch = false

    kill_switch = true if params[:join_code].blank?

    unless kill_switch
      game = Game.find_by(join_code: params[:join_code])
      kill_switch = true if( game.blank? || !game.pregame? )
    end

    unless kill_switch
      kill_switch = true unless game.lobby_a_new_user(current_user.id)
    end

    unless kill_switch
      stop_all_streams
      stream_from "lobby_#{params[:join_code]}"


      html = render_user_partial_for_game( params[:join_code] )

      ActionCable.server.broadcast("lobby_#{params[:join_code]}", partial: html)
    end
  end

  def unsubscribed
    # stop_all_streams
    # close
  end

  def join_game data_hash
    game = current_user.current_game
    game.commit_a_lobbyed_user( current_user.id, data_hash['users_game_name'].strip )
    html = render_user_partial_for_game( game.join_code )
    ActionCable.server.broadcast("lobby_#{game.join_code}", partial: html)
  end

  def unjoin_game
    game = Game.find_by(join_code: params[:join_code])

    info = {}
    game.remove_player(current_user.id)

    info = {
             user_leaving: {
                             user_id: current_user.id.to_s,
                             url: choose_game_type_page_path
                           }
           }

    if game.users.count > 0
      info[:partial] = render_user_partial_for_game( params[:join_code] )
    end

    ActionCable.server.broadcast("lobby_#{params[:join_code]}", info)
    sleep 0.25
    stop_all_streams
  end

  def start_game
    if(Game.start_game params[:join_code])
      # broadcast a message to try and go to the game start page. The before action will allow the commited people through to their game and send the uncommited people back to the game choice page.
      ActionCable.server.broadcast("lobby_#{params[:join_code]}", start_game_signal: new_game_path)
    end
  end

  protected

    def render_user_partial_for_game join_code
      game = Game.find_by(join_code: join_code)
      @users_not_joined = game.unassociated_rendezousing_games_users
      @users_joined = Game.all_users_game_names(game.join_code)
      ApplicationController.render(partial: 'lobbies/currently_joined', locals: { users_not_joined: @users_not_joined, users_joined: @users_joined })
    end
end

