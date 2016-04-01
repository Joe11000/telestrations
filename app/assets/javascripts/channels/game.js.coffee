App.game = App.cable.subscriptions.create { channel: "GameChannel", join_code: $('[data-id=randezvous-join-code]').html() },
# App.game = App.cable.subscriptions.create { channel: "GameChannel", game_join_code: 'AAAA'},
  connected: ->
    # console.log('connected')
    $('.loading-gif').removeClass('invisible');
    # @join_game
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $("[data-id=currently-joined]").replaceWith(data.content);

    # Called when there's incoming data on the websocket for this channel

  # start_game: ->
  #   # @perform 'start_game'

  # join_game: ->
  #   # @perform 'join_game', $("[data-id='update-rendezvous-form-group'] input")

  # unjoin_game: ->
  #   # @perform 'unjoin_game'
