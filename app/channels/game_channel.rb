# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def start_game
  end

  def join_game
  end

  def unjoin_game
  end

  protected
    def render_users
      # ApplicationController.render(partial: 'messages/message', locals: { message: message })
    end
end
