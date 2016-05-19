# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_id]}" unless params[:game_id].blank?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end



  # { type: "description", text: "Suicidal Penguin", prev_card: nil }
  # { type: "drawing", file: "Suicidal Penguin", prev_card: nil }

  # { drawing: "FILE", prev_card: nil }

  # def card_submission

  #   case params[:type]
  #   when "description"
  #     description_submitted params
  #     break
  #   when "drawing"
  #     drawing_submitted params


  # end

  # protected

    # def description_submitted

    #   prev_card = Card.find_by(id: params[:prev_card])

    #   gu = current_user.gamesuser_in_current_game
    #   game = gu.game

    #   if prev_card.blank?
    #     debugger
    #     # This is initial card
    #     gu.starting_card = Card.create( drawing_or_description: "description",
    #                                                            description_text: params[:description],
    #                                                            association: current_user.id,
    #                                                            idea_catalyst: gu.id )



    #   else

    #   # { description: "Suicidal Penguin", prev_card: 7 }

    #       prev_card.child_card.create( drawing_or_description: "description",
    #                                    description_text: params[:description],
    #                                    association: current_user.id )

    #   end

    #   # current_user is updated with new card if available
    #   ActionCable.server.broadcast("game_#{params[:game_id]}", { players_concerned: game.next_player_after current_user.id, type: })

    #   # check if next player in line is waiting for this card new card available, if they are waiting for it
    #   ActionCable.server.broadcast("game_#{params[:game_id]}", { players_concerned: game.parse_passing_order })
    #   # current_user.starting_card_in_current_game
    # end




end
