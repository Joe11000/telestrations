class OutOfGameCardUploadsController
  class OutOfGameCardUploadsInfoGenerator
    attr_reader :current_user

    def initialize current_user:
      @current_user = current_user
    end

    def result
      out_of_game_cards
    end

    private
      def out_of_game_cards
        Card.drawing.where(out_of_game_card_upload: true, uploader: current_user)

        out_of_game_cards = GamesUser.where(user: current_user).last.cards.order(desc: :id).map do |card|
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
  end
end
