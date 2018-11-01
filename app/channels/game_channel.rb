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
end
