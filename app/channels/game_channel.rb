# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    game = Game.find_by(join_code: params[:join_code])
    stream_for game
  end

  # def follow
  #   byebug
  #   stop_all_streams
  # end

  def unsubscribed
    stop_all_streams
  end


  # def unfollow
  #   byebug
  #   stop_all_streams
  # end



  # def join_game join_code
  #   byebug
  #   # assign_player_to_game
  #   # ActionCable.server.broadcast('games', message: render_user_partial())
  # end

  # def unjoin_game
  #   byebug

  #   # ActionCable.server.broadcast('games', message: render_user_partial())
  # end

  # def start_game
  #   byebug

  # end

  protected
    # def assign_player_to_game update_params
    #   # delete an association to another pregame game
    #     association = current_user.gamesuser_in_current_game
    #     association.destroy unless association.blank?

    #   # create user association to game
    #     GamesUser.create(user_id: current_user.id, game_id: @game.id, users_game_name: update_params)
    # end

    def render_user_partial
      ApplicationController.render(partial: 'rendezvous/currently_joined',
                                   locals: { message: users_arr })
    end
end
