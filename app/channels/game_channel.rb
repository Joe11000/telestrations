# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  include Rails.application.routes.url_helpers

  # {channel: "GameChannel", prev_card: num || '', game_id: num || ''}
  def subscribed
    stream_from "game_#{current_user.current_game.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end


  # input a XOR b
  # a) { prev_card: nil, description_text: "Suicidal Penguin"}
  # b) { prev_card: nil, filename: file.filename,  data: file.data };
  # def upload_card upload_card_params
  #   byebug
  #   current_user_game = current_user.current_game


  #   updated_card = current_user_game.try(:upload_info_into_placeholder_card, current_user.id, upload_card_params)

  #   if card.description && upload_card_params.dig('description_text').present?
  #     card.update(description_text: upload_card_params['description_text'])
  #   elsif card.drawing && upload_card_params.dig('').present?
  #     card.drawing.attach upload_card_params
  #   end

  #   return false if updated_card == false

  #   # set up the placeholder for the next players turn and get params that should be broadcasted to notify users of a card being finished
  #   broadcast_params = current_user_game.set_up_next_players_turn updated_card.id

  #   current_user_game.send_out_broadcasts_to_players_after_card_upload broadcast_params
  # end


end


  # working!!!
  # params :  a XOR b
    # a) upload_card_params: { 'description_text' => "Suicidal Penguin"}
    # b) upload_card_params: { 'filename' => file.filename,  data: file.data };
  # def upload_info_into_placeholder_card current_user_id, upload_card_params
  #   current_user = users.find_by(id: current_user_id)
  #   card = get_placeholder_card current_user_id


  #   return false if current_user.blank? || card.blank?
  #   if card.description && upload_card_params.dig('description_text').present?
  #     card.update(description_text: upload_card_params['description_text'])
  #   else
  #     card.drawing.attach upload_card_params
  #   end

  #   return card
  # end
