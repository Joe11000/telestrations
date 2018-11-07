require 'json'

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
end
