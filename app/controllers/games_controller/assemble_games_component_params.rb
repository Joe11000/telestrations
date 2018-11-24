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
      @game = current_user.games.postgame.find(game.id) # make sure game is attached to user
    end

    def result_to_json
      @result_to_json ||= result.to_json
    end


    private

      #####  recreated ActiveStorageUrlCreater because couldn't do it another way
      include Rails.application.routes.url_helpers
      def get_drawing_url card
        unless (card.drawing? && card.drawing.attached?)
          raise 'Card must be a drawing with an image attached'
        end

        return rails_blob_path(card.drawing, disposition: 'attachment', only_path: true)
      end
      ######

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
          result.merge!( {'drawing_url' => get_drawing_url(card)} )
        else
          card.slice(:medium, :description_text, :uploader)
        end
        result
      end

      def arr_of_postgame_card_set
        Card.cards_from_finished_game(game.id)
      end


      def all__current_user__game_info
        current_user.games.map do |game|
          result = game.slice(:id)
          result.merge!( { 'created_at_strftime' => game.created_at.strftime('%a %b %e, %Y') } )
        end
      end

      def result
        byebug
        @result ||= begin
          # want to pass down who the player was in each game so that i can highlight their games_user_name in the (postgame_page + all_postgames_page)
          postgame_component_params = {
                                        current_user: current_user.attributes,
                                        out_of_game_cards: out_of_game_cards,
                                        arr_of_postgame_card_set: arr_of_postgame_card_set.attributes,
                                        all__current_user__game_info: all__current_user__game_info
                                      }
        end

        return @result
      end
  end
end
