App.game = App.cable.subscriptions.create { channel: "GameChannel", game_id: $('[data-game-id]').attr('data-game-id') }
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
