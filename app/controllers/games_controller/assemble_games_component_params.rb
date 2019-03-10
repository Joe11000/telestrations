require 'json'
require File.join(Rails.root, 'app', 'services', 'active_storage_url_creater')

class GamesController
  class AssembleGamesComponentParams

    def initialize current_user:, game:, form_authenticity_token:
      @current_user = current_user
      @game = game
      @form_authenticity_token = form_authenticity_token
    end

    def result
      return @result ||= begin
                          _result = @game.get_status_for_users([@current_user])

                          unless @game.game_over?
                            # update each status with a form_authenticity_token for each form
                            unless @game.is_player_finished? @current_user.id
                              add__authenticity_tokens__to_statuses _result
                              add__back_up_starting_description__if_needed _result
                            end

                            _result[:current_user_id] = @current_user.id
                          end

                          _result
                        end
    end

    def result_to_json
      @result_to_json ||= result.to_json
    end

    private

      def add__back_up_starting_description__if_needed _result
        _starting_card = @current_user.current_games_user.starting_card
        if _starting_card.try(:description?) && _starting_card.try(:placeholder)
          _result[:back_up_starting_description] = back_up_starting_description
        end
      end

      def add__authenticity_tokens__to_statuses result
        result[:statuses].each do |status|
          status[:form_authenticity_token] = @form_authenticity_token
        end
      end

      def back_up_starting_description
        TokenPhrase.generate(' ', numbers: false)
      end
  end

  class AssemblePostgamesComponentParams

    attr_reader :current_user, :game

    def initialize current_user:, game: nil
      @current_user = current_user
      @game = game
    end

    def result_to_json
      @result_to_json ||= result.to_json
    end

    private

      def arr_of_postgame_card_set
        Card.cards_from_finished_game(game.id)
      end


      def all_postgames_of__current_user
        current_user.games.postgame.map do |game|
          result = game.slice(:id)
          result.merge!( { 'created_at_strftime' => game.created_at.strftime('%a %b %e, %Y') } )
        end
      end

      def current_user_info 
        current_user.slice(:id, :name)
      end

      def result
        @postgame_component_params ||= begin
          {
            'current_user_info' => current_user_info,
            
            'PostGameTab' => {
                               'all_postgames_of__current_user' => all_postgames_of__current_user,
                               'current_postgame_id' => game.id,
                               'storage_of_viewed_postgames' => { game.id => arr_of_postgame_card_set }
                             }
          };
        end

        return @postgame_component_params
      end
  end
end
