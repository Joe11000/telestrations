class RendezvousController < ApplicationController
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_currently_playing_game

  layout proc { false if request.xhr? }

  def choose_game_type_page
  end

  # joining a game
  def join_game
    byebug
    @game = Game.find_by(join_code: join_game_params.upcase)
    if @game.blank?
      redirect_to(rendezvous_choose_game_type_page_url, alert: "Group #{join_game_params} doesn't exist.") and return
    else
      redirect_to rendezvous_page_path(@game.game_type) and return
    end
  end

  def rendezvous_page
    respond_to do |format|
      format.html do

        @game = current_user.current_game

        # user associated with another pregame that has a different status and wants to join another game. This will only happen when user uses browser's back button instead of the "Leave Group" button on the rendezvous page
        if @game.try(:pregame?) && different_game_type_chosen?(params[:game_type], @game.game_type)
          @game.remove_player current_user.id
          @game = nil
        end

        if @game.blank?
          @user_already_joined = false

          case params[:game_type]
            when 'private'
              @game = Game.create(game_type: :private)
            when 'public'
              @game = Game.create(game_type: :public)
            when 'quick_start'
              @game = Game.random_public_game

              if @game.blank?
                @game = Game.create(game_type: :public)
              else
                @game.touch
              end
          end
        # elsif @game.pregame? && params[:game_type] != @game.game_type # user associated with another pregame that has a different status

        #   @game.remove_player current_user.id
        #   @user_already_joined = false

        elsif @game.pregame? && current_user.current_games_user_name  # user already joined this game
          @user_already_joined = true
        elsif @game.pregame?
          @user_already_joined = false
        else
          raise "shouldn't have gotten here, something is wrong: game_id: #{@game.try(:id)}, current_user_id: #{current_user.id}"
        end

        @users_not_joined = @game.unassociated_rendezousing_games_users
        @users_joined = Game.all_users_game_names @game.join_code
      end
    end
  end

  # def leave_pregame
  #   byebug
  #   current_user.current_game.try(:remove_player, current_user.id)
  #   redirect_to(rendezvous_choose_game_type_page_url) and return
  # end

protected
  def join_game_params
    params.require(:join_code)
  end

  def update_params
    params.require(:users_game_name)
  end

  def redirect_if_currently_playing_game
    redirect_to games_url if current_user.current_game.try(:status) == 'midgame'
  end

  def different_game_type_chosen? params_game_type, game__game_type
    ((params_game_type != game__game_type ) && (params_game_type == 'private' || game__game_type == 'private'))
  end
end

