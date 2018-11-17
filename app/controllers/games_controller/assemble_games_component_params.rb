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

  class AssemblePostgamesComponentParams
    attr_reader :current_user, :game

    def initialize current_user:, game: nil
      @current_user = current_user
      @game = current_user.games.postgame.find(game.id) # make sure game is attached to user
    end

    def result_to_json
      @result_to_json ||= result.to_json
    end

    private

      def out_of_game_cards
        Card.where(out_of_game_card_upload: true, uploader: current_user)

        out_of_game_cards = GamesUser.where(user: current_user).last.cards.map do |card|
          pull_info_from card
        end
      end

      def pull_info_from card
        result = nil

        if card.drawing?
          result = card.slice(:medium, :uploader)
          byebug
          result.merge!( {'drawing_url' => get_drawing_url(card)} )
          result
        else
          card.slice(:medium, :description_text, :uploader)
        end
        result
      end

      def arr_of_postgame_card_set
        Card.cards_from_finished_game(game.id)
      end

      def result
        @result ||= begin
          # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)
          postgame_component_params = {
                                        current_user: current_user.to_json,
                                        out_of_game_cards: out_of_game_cards,
                                        arr_of_postgame_card_set: arr_of_postgame_card_set.to_json,
                                        all__current_user__game_ids: current_user.game_ids
                                      }
        end

        return @result
      end
  end
end
