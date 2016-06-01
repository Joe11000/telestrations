# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    current_user_game = current_user.current_game
    stream_from "game_#{params[:game_id]}" if current_user_game.try(:id) == params[:game_id]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end


  # input a XOR b
  # a) { prev_card: nil, description_text: "Suicidal Penguin"}
  # b) { prev_card: nil, filename: file.filename,  data: file.data  };
  def upload_card upload_card_params
    byebug
    current_user_game = current_user.current_game
    updated_card = current_user_game.try(:upload_info_into_existing_card)
    return false if updated_card == false

    # set up the placeholder for the next players turn and get params that should be broadcasted to notify users of a card being finished
    broadcast_params = current_user_game.set_up_next_players_turn updated_card.id

    current_user_game.send_out_broadcasts_to_players_after_card_upload broadcast_params
  end

end
