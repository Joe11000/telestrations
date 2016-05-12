class RendezvousController < ApplicationController

  before_action :redirect_if_not_logged_in
  before_action :redirect_if_currently_playing_game

  layout proc { false if request.xhr? }

  def choose_game_type_page
    render :choose_game_type_page, layout: 'application'
  end

  # joining a game
  def join_game
    @game = Game.find_by(join_code: join_game_params)
    if @game.blank?
      redirect_to(rendezvous_choose_game_type_page_path, alert: "No players in group #{join_game_params}") and return
    else
      @game.touch # remember activity for deleting if inactive later
      @users_waiting = Game.all_users_game_names(@game.id)
      render :rendezvous_page and return
    end
  end

  def rendezvous_page
    case params[:game_type]
      when 'private'
        @game = Game.create(is_private: true)
      when 'public'
        @game = Game.create(is_private: false)
      when 'quick_start'
        @game = Game.random_public_game
        if @game.blank?
          @game = Game.create(is_private: false)
        else
          @game.touch
        end
      else
        redirect_to rendezvous_choose_game_type_page_path and return
      end

    @users_waiting = @game.users.map(&:users_game_name)
    @game.touch # remember activity for deleting if inactive later
    render :rendezvous_page
  end

  def leave_pregame
    current_user.leave_current_game
    redirect_to rendezvous_choose_game_type_page_path
  end

protected
  def join_game_params
    params.require(:join_code)
  end

  def update_params
    params.require(:users_game_name)
  end

  def redirect_if_currently_playing_game
    redirect_to game_page_path if current_user.current_game.try(:status) == 'midgame'
  end
end
